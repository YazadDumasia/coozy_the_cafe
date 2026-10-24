import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;

import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../entities/p2p_sync_config.dart';

/// Local Peer-to-Peer / Offline Multi-Device Sync Service
/// Operates on local Wi-Fi without internet access.
///
/// POS Station:
///  - Listens on WebSocket / HTTP Server (Port 8899).
///  - Broadcasts UDP Beacon on Port 8898 (`COOZY_HUB:<IP>:<PORT>`).
///  - Receives orders/updates from Waiter/KDS tablets and merges them into Drift SQLite.
///  - Broadcasts order mutations to all connected client tablets.
///
/// Waiter / KDS Station:
///  - Listens for UDP Beacon to discover POS Hub IP:Port automatically.
///  - Connects to POS Hub via WebSocket.
///  - Pushes newly placed or modified orders to POS Hub.
///  - Listens for real-time order updates pushed by POS Hub and updates local Drift SQLite.
class LocalP2pSyncService {
  LocalP2pSyncService._();

  static final LocalP2pSyncService instance = LocalP2pSyncService._();

  static const int defaultPort = 8899;
  static const int discoveryPort = 8898;
  static const String beaconPrefix = 'COOZY_HUB';

  HttpServer? _server;
  final List<WebSocket> _connectedClients = [];
  WebSocket? _clientSocket;

  RawDatagramSocket? _udpBeaconSocket;
  RawDatagramSocket? _udpDiscoverySocket;
  Timer? _beaconTimer;
  Timer? _heartbeatTimer;

  // Offline queue for storing mutations while disconnected
  final List<String> _offlineOutbox = [];

  final ValueNotifier<SyncConnectionStatus> statusNotifier =
      ValueNotifier<SyncConnectionStatus>(SyncConnectionStatus.idle);
  final ValueNotifier<int> clientCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> localIpNotifier = ValueNotifier<String>('');
  final ValueNotifier<String?> lastSyncMessageNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<int> pendingOutboxCountNotifier = ValueNotifier<int>(0);

  P2pSyncConfig _currentConfig = const P2pSyncConfig();
  CoozyDatabase? _database;

  P2pSyncConfig get currentConfig => _currentConfig;

  void attachDatabase(CoozyDatabase database) {
    _database = database;
  }

  /// Load persisted configuration and start services if enabled
  Future<void> initialize({CoozyDatabase? database}) async {
    if (database != null) {
      _database = database;
    }
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(shared.PreferencesKeys.p2pSyncConfig.name);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      _currentConfig = P2pSyncConfig.fromJson(jsonStr);
    }

    if (!kIsWeb && _currentConfig.isEnabled) {
      await startSync();
    }
  }

  /// Save configuration and restart sync if needed
  Future<void> saveConfig(P2pSyncConfig config) async {
    _currentConfig = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      shared.PreferencesKeys.p2pSyncConfig.name,
      config.toJson(),
    );

    await stopSync();
    if (config.isEnabled) {
      await startSync();
    }
  }

  /// Detects the device's local Wi-Fi / LAN IP address
  Future<String?> getLocalIpAddress() async {
    if (kIsWeb) return null;
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && addr.address.contains('.')) {
            localIpNotifier.value = addr.address;
            return addr.address;
          }
        }
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        LocalP2pSyncService,
        'Error retrieving local IP address: $e',
      );
    }
    return null;
  }

  /// Starts sync based on configured role
  Future<void> startSync() async {
    if (kIsWeb) return;
    await stopSync();

    final ip = await getLocalIpAddress();

    if (_currentConfig.role == DeviceSyncRole.posHub) {
      await _startHubServer(ip);
    } else if (_currentConfig.role == DeviceSyncRole.clientTerminal) {
      await _startClientTerminal(ip);
    }
  }

  /// Stops all active servers, client sockets, and UDP beacons
  Future<void> stopSync() async {
    _beaconTimer?.cancel();
    _beaconTimer = null;

    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    try {
      _udpBeaconSocket?.close();
      _udpBeaconSocket = null;
    } catch (_) {}

    try {
      _udpDiscoverySocket?.close();
      _udpDiscoverySocket = null;
    } catch (_) {}

    for (final client in _connectedClients) {
      try {
        await client.close();
      } catch (_) {}
    }
    _connectedClients.clear();
    clientCountNotifier.value = 0;

    try {
      await _clientSocket?.close();
      _clientSocket = null;
    } catch (_) {}

    try {
      await _server?.close(force: true);
      _server = null;
    } catch (_) {}

    statusNotifier.value = SyncConnectionStatus.idle;
  }

  // ==========================================
  // POS HUB (SERVER) IMPLEMENTATION
  // ==========================================

  Future<void> _startHubServer(String? ip) async {
    try {
      statusNotifier.value = SyncConnectionStatus.hosting;
      final port = _currentConfig.hubPort > 0
          ? _currentConfig.hubPort
          : defaultPort;

      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        port,
        shared: true,
      );

      core.PlatformUtils.debugLog(
        LocalP2pSyncService,
        'POS Hub server running at port $port (Local IP: $ip)',
      );

      _server!.listen(
        (HttpRequest request) async {
          if (WebSocketTransformer.isUpgradeRequest(request)) {
            final socket = await WebSocketTransformer.upgrade(request);
            _handleClientConnection(socket);
          } else if (request.method == 'GET' && request.uri.path == '/status') {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.json
              ..write(
                jsonEncode({
                  'status': 'online',
                  'role': 'posHub',
                  'connectedClients': _connectedClients.length,
                }),
              );
            await request.response.close();
          } else {
            request.response
              ..statusCode = HttpStatus.notFound
              ..write('Coozy POS Hub Service');
            await request.response.close();
          }
        },
        onError: (e) {
          core.PlatformUtils.debugLog(
            LocalP2pSyncService,
            'Error on Hub Server: $e',
          );
        },
      );

      // Start UDP Broadcast Beacon
      _startUdpBeacon(ip, port);
    } catch (e) {
      statusNotifier.value = SyncConnectionStatus.error;
      core.PlatformUtils.debugLog(
        LocalP2pSyncService,
        'Failed to start POS Hub Server: $e',
      );
    }
  }

  void _startUdpBeacon(String? ip, int port) async {
    if (ip == null || ip.isEmpty) return;
    try {
      _udpBeaconSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
      );
      _udpBeaconSocket!.broadcastEnabled = true;

      final message = utf8.encode('$beaconPrefix:$ip:$port');
      final target = InternetAddress('255.255.255.255');

      _beaconTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        try {
          _udpBeaconSocket?.send(message, target, discoveryPort);
        } catch (_) {}
      });
    } catch (e) {
      core.PlatformUtils.debugLog(
        LocalP2pSyncService,
        'Failed to start UDP beacon: $e',
      );
    }
  }

  void _handleClientConnection(WebSocket client) {
    _connectedClients.add(client);
    clientCountNotifier.value = _connectedClients.length;
    lastSyncMessageNotifier.value =
        'Client connected (${_connectedClients.length} online)';

    client.listen(
      (data) {
        _onHubReceivedMessage(data, client);
      },
      onDone: () {
        _connectedClients.remove(client);
        clientCountNotifier.value = _connectedClients.length;
      },
      onError: (_) {
        _connectedClients.remove(client);
        clientCountNotifier.value = _connectedClients.length;
      },
    );
  }

  Future<void> _onHubReceivedMessage(dynamic rawData, WebSocket sender) async {
    try {
      final json = jsonDecode(rawData as String) as Map<String, dynamic>;
      final type = json['type'] as String?;

      if (type == 'PING') {
        try {
          sender.add(jsonEncode({'type': 'PONG', 'timestamp': DateTime.now().millisecondsSinceEpoch}));
        } catch (_) {}
        return;
      }

      if (type == 'PUSH_ORDER' && _database != null) {
        final orderData = json['order'] as Map<String, dynamic>;
        final itemsData =
            (json['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        await _mergeOrderIntoDatabase(orderData, itemsData);

        // Broadcast to all other connected client tablets (e.g. KDS screens)
        final relayPayload = jsonEncode({
          'type': 'ORDER_BROADCAST',
          'order': orderData,
          'items': itemsData,
        });

        for (final client in _connectedClients) {
          if (client != sender) {
            try {
              client.add(relayPayload);
            } catch (_) {}
          }
        }
      } else if (type == 'UPDATE_ITEM_STATUS' && _database != null) {
        final itemId = json['itemId'] as int?;
        final status = json['status'] as String?;
        if (itemId != null && status != null) {
          await _database!.kitchenOrdersDao.updateOrderItemStatus(
            itemId,
            status,
          );

          // Relay status update to all connected terminals
          for (final client in _connectedClients) {
            if (client != sender) {
              try {
                client.add(rawData);
              } catch (_) {}
            }
          }
        }
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        LocalP2pSyncService,
        'Error handling Hub received message: $e',
      );
    }
  }

  // ==========================================
  // CLIENT TERMINAL (WAITER / KDS) IMPLEMENTATION
  // ==========================================

  Future<void> _startClientTerminal(String? ip) async {
    if (_currentConfig.autoDiscover) {
      _startUdpDiscovery();
    } else if (_currentConfig.hubIpAddress.isNotEmpty) {
      _connectToHub(
        _currentConfig.hubIpAddress,
        _currentConfig.hubPort > 0 ? _currentConfig.hubPort : defaultPort,
      );
    }
  }

  void _startUdpDiscovery() async {
    try {
      statusNotifier.value = SyncConnectionStatus.discovering;
      _udpDiscoverySocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
        reuseAddress: true,
        reusePort: false,
      );
      _udpDiscoverySocket!.broadcastEnabled = true;

      _udpDiscoverySocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _udpDiscoverySocket?.receive();
          if (datagram != null) {
            final message = utf8.decode(datagram.data);
            if (message.startsWith(beaconPrefix)) {
              final parts = message.split(':');
              if (parts.length >= 3) {
                final hubIp = parts[1];
                final hubPort = int.tryParse(parts[2]) ?? defaultPort;
                _udpDiscoverySocket?.close();
                _udpDiscoverySocket = null;
                _connectToHub(hubIp, hubPort);
              }
            }
          }
        }
      });
    } catch (e) {
      core.PlatformUtils.debugLog(
        LocalP2pSyncService,
        'Error in UDP discovery: $e',
      );
      // Fallback to configured manual IP if available
      if (_currentConfig.hubIpAddress.isNotEmpty) {
        _connectToHub(_currentConfig.hubIpAddress, _currentConfig.hubPort);
      }
    }
  }

  Future<void> _connectToHub(String hubIp, int hubPort) async {
    try {
      statusNotifier.value = SyncConnectionStatus.connecting;
      final uri = Uri.parse('ws://$hubIp:$hubPort');
      _clientSocket = await WebSocket.connect(uri.toString()).timeout(
        const Duration(seconds: 5),
      );

      statusNotifier.value = SyncConnectionStatus.connected;
      lastSyncMessageNotifier.value = 'Connected to POS Hub ($hubIp:$hubPort)';

      // Start client heartbeat ping (every 10s)
      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (_clientSocket != null) {
          try {
            _clientSocket!.add(jsonEncode({'type': 'PING', 'timestamp': DateTime.now().millisecondsSinceEpoch}));
          } catch (_) {
            _handleClientDisconnect();
          }
        }
      });

      // Flush any queued offline mutations
      _flushOfflineOutbox();

      _clientSocket!.listen(
        (data) {
          _onClientReceivedMessage(data);
        },
        onDone: () {
          _handleClientDisconnect();
        },
        onError: (e) {
          _handleClientDisconnect(isError: true);
        },
      );
    } catch (e) {
      _handleClientDisconnect();
    }
  }

  void _handleClientDisconnect({bool isError = false}) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    statusNotifier.value =
        isError ? SyncConnectionStatus.error : SyncConnectionStatus.disconnected;
    _scheduleReconnect();
  }

  void _flushOfflineOutbox() {
    if (_clientSocket == null || _offlineOutbox.isEmpty) return;
    final toSend = List<String>.from(_offlineOutbox);
    _offlineOutbox.clear();
    pendingOutboxCountNotifier.value = 0;

    for (final payload in toSend) {
      try {
        _clientSocket!.add(payload);
      } catch (e) {
        _offlineOutbox.add(payload);
      }
    }
    pendingOutboxCountNotifier.value = _offlineOutbox.length;
  }

  void _scheduleReconnect() {
    if (_currentConfig.isEnabled &&
        _currentConfig.role == DeviceSyncRole.clientTerminal) {
      Timer(const Duration(seconds: 5), () {
        if (statusNotifier.value != SyncConnectionStatus.connected) {
          startSync();
        }
      });
    }
  }

  Future<void> _onClientReceivedMessage(dynamic rawData) async {
    try {
      final json = jsonDecode(rawData as String) as Map<String, dynamic>;
      final type = json['type'] as String?;

      if (type == 'ORDER_BROADCAST' && _database != null) {
        final orderData = json['order'] as Map<String, dynamic>;
        final itemsData =
            (json['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        await _mergeOrderIntoDatabase(orderData, itemsData);
      } else if (type == 'UPDATE_ITEM_STATUS' && _database != null) {
        final itemId = json['itemId'] as int?;
        final status = json['status'] as String?;
        if (itemId != null && status != null) {
          await _database!.kitchenOrdersDao.updateOrderItemStatus(
            itemId,
            status,
          );
        }
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        LocalP2pSyncService,
        'Error on client received message: $e',
      );
    }
  }

  // ==========================================
  // SYNC ACTION DISPATCHERS
  // ==========================================

  /// Broadcast a newly placed or updated order to peers over Wi-Fi
  Future<void> broadcastOrder({
    required Map<String, dynamic> orderMap,
    required List<Map<String, dynamic>> itemsList,
  }) async {
    if (!_currentConfig.isEnabled) return;

    final payload = jsonEncode({
      'type': 'PUSH_ORDER',
      'order': orderMap,
      'items': itemsList,
    });

    if (_currentConfig.role == DeviceSyncRole.posHub) {
      for (final client in _connectedClients) {
        try {
          client.add(payload);
        } catch (_) {}
      }
    } else if (_currentConfig.role == DeviceSyncRole.clientTerminal) {
      if (_clientSocket != null) {
        try {
          _clientSocket!.add(payload);
        } catch (_) {
          _offlineOutbox.add(payload);
          pendingOutboxCountNotifier.value = _offlineOutbox.length;
        }
      } else {
        _offlineOutbox.add(payload);
        pendingOutboxCountNotifier.value = _offlineOutbox.length;
      }
    }
  }

  /// Broadcast an order item status update (e.g. Preparing -> Ready -> Served)
  Future<void> broadcastItemStatusUpdate({
    required int itemId,
    required String status,
  }) async {
    if (!_currentConfig.isEnabled) return;

    final payload = jsonEncode({
      'type': 'UPDATE_ITEM_STATUS',
      'itemId': itemId,
      'status': status,
    });

    if (_currentConfig.role == DeviceSyncRole.posHub) {
      for (final client in _connectedClients) {
        try {
          client.add(payload);
        } catch (_) {}
      }
    } else if (_currentConfig.role == DeviceSyncRole.clientTerminal) {
      if (_clientSocket != null) {
        try {
          _clientSocket!.add(payload);
        } catch (_) {
          _offlineOutbox.add(payload);
          pendingOutboxCountNotifier.value = _offlineOutbox.length;
        }
      } else {
        _offlineOutbox.add(payload);
        pendingOutboxCountNotifier.value = _offlineOutbox.length;
      }
    }
  }

  // ==========================================
  // DATABASE MERGE HELPER
  // ==========================================

  Future<void> _mergeOrderIntoDatabase(
    Map<String, dynamic> orderMap,
    List<Map<String, dynamic>> itemsList,
  ) async {
    if (_database == null) return;

    try {
      final hashId = orderMap['hashId'] as String? ?? '';
      if (hashId.isEmpty) return;

      // Check if order exists by hashId or id
      final existing = await (_database!.select(
        _database!.ordersTable,
      )..where((t) => t.hashId.equals(hashId))).getSingleOrNull();

      final nowUtc = DateTime.now().toUtc().toIso8601String();

      await _database!.transaction(() async {
        int orderId;
        if (existing != null) {
          orderId = existing.id;
          await (_database!.update(
            _database!.ordersTable,
          )..where((t) => t.id.equals(orderId))).write(
            OrdersTableCompanion(
              tableInfoId: drift.Value(orderMap['tableInfoId'] as int?),
              tableNameText: drift.Value(orderMap['tableNameText'] as String?),
              status: drift.Value(orderMap['status'] as String?),
              orderType: drift.Value(orderMap['orderType'] as String?),
              grandTotal: drift.Value(
                (orderMap['grandTotal'] as num?)?.toDouble() ?? 0.0,
              ),
              modificationDate: drift.Value(nowUtc),
            ),
          );
        } else {
          final comp = OrdersTableCompanion(
            hashId: drift.Value(hashId),
            tableInfoId: drift.Value(orderMap['tableInfoId'] as int?),
            tableNameText: drift.Value(orderMap['tableNameText'] as String?),
            status: drift.Value(orderMap['status'] as String? ?? 'newOrder'),
            orderType: drift.Value(orderMap['orderType'] as String? ?? 'Dine-In'),
            customerName: drift.Value(orderMap['customerName'] as String?),
            phoneNumber: drift.Value(orderMap['phoneNumber'] as String?),
            subtotalAmount: drift.Value(
              (orderMap['subtotalAmount'] as num?)?.toDouble() ?? 0.0,
            ),
            grandTotal: drift.Value(
              (orderMap['grandTotal'] as num?)?.toDouble() ?? 0.0,
            ),
            creationDate: drift.Value(
              orderMap['creationDate'] as String? ?? nowUtc,
            ),
            placedAt: drift.Value(nowUtc),
          );
          orderId = await _database!.into(_database!.ordersTable).insert(comp);
        }

        // Upsert items
        for (final item in itemsList) {
          final itemId = item['itemId'] as int?;
          if (itemId == null) continue;

          final existingItem = await (_database!.select(
            _database!.orderItemsTable,
          )..where(
            (t) => t.orderId.equals(orderId) & t.itemId.equals(itemId),
          )).getSingleOrNull();

          if (existingItem != null) {
            await (_database!.update(
              _database!.orderItemsTable,
            )..where((t) => t.id.equals(existingItem.id))).write(
              OrderItemsTableCompanion(
                quantity: drift.Value(item['quantity'] as int?),
                status: drift.Value(item['status'] as String?),
                remarks: drift.Value(item['remarks'] as String?),
              ),
            );
          } else {
            await _database!.into(_database!.orderItemsTable).insert(
              OrderItemsTableCompanion(
                orderId: drift.Value(orderId),
                itemId: drift.Value(itemId),
                quantity: drift.Value(item['quantity'] as int? ?? 1),
                sellingPrice: drift.Value(
                  (item['sellingPrice'] as num?)?.toDouble() ?? 0.0,
                ),
                status: drift.Value(item['status'] as String? ?? 'pending'),
                remarks: drift.Value(item['remarks'] as String?),
                creationDate: drift.Value(nowUtc),
                placedAt: drift.Value(nowUtc),
              ),
            );
          }
        }
      });

      lastSyncMessageNotifier.value = 'Order synced: Table ${orderMap['tableNameText']}';
    } catch (e) {
      core.PlatformUtils.debugLog(
        LocalP2pSyncService,
        'Error merging synced order: $e',
      );
    }
  }
}

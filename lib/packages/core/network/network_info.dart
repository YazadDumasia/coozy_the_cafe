import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<InternetStatus> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection _connectionChecker;

  /// Creates a [NetworkInfoImpl].
  /// An [InternetConnection] instance can be injected for testing;
  /// if omitted, a default instance is created internally.
  NetworkInfoImpl([InternetConnection? connectionChecker])
    : _connectionChecker = connectionChecker ?? InternetConnection();

  @override
  Future<bool> get isConnected async {
    // if (kIsWeb) {
    //   // In web browsers, CORS policies block cross-origin ping requests
    //   // executed by internet_connection_checker_plus (returning false).
    //   // Since the app has already loaded over HTTP/HTTPS in the browser, treat as connected.
    //   return true;
    // }
    return _connectionChecker.hasInternetAccess;
  }

  @override
  Stream<InternetStatus> get onStatusChange =>
      _connectionChecker.onStatusChange;
}

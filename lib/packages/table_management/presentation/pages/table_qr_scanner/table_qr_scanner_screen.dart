import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';

class TableQrScannerScreen extends StatefulWidget {
  const TableQrScannerScreen({super.key});

  @override
  State<TableQrScannerScreen> createState() => _TableQrScannerScreenState();
}

class _TableQrScannerScreenState extends State<TableQrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  int? _parseTableId(String code) {
    final trimmed = code.trim();
    if (trimmed.startsWith('coozy_table:')) {
      final part = trimmed.substring('coozy_table:'.length);
      return int.tryParse(part);
    }
    return int.tryParse(trimmed);
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    final tableId = _parseTableId(rawValue);
    if (tableId == null) {
      if (!mounted) return;
      shared.DialogUtils.showAutoDismissDialog(
        context: context,
        title:
            context.tr(
              shared.LocaleKeys.commonError,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Invalid QR',
        descriptions:
            context.tr(
              shared.LocaleKeys.qrScanInvalidFormatMsg,
              track: shared.TrackConstants.tablePageTrack,
            ) ??
            'Invalid QR code format for table scanning.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    await _scannerController.stop();

    if (!mounted) return;

    shared.DialogUtils.showLoadingDialog(context);

    try {
      final waiterRepo = sl<WaiterOrderPlacementRepository>();
      final result = await waiterRepo.getActiveTableOrders();

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      result.fold(
        (failure) {
          shared.DialogUtils.showAutoDismissDialog(
            context: context,
            title:
                context.tr(
                  shared.LocaleKeys.commonError,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Error',
            descriptions: failure.message,
          );
          setState(() {
            _isProcessing = false;
          });
          _scannerController.start();
        },
        (activeOrders) {
          final matchingOrder = activeOrders.cast<dynamic>().firstWhere(
            (o) => o.tableId == tableId,
            orElse: () => null,
          );

          final tableNameDisplay = 'TABLE $tableId';

          if (matchingOrder != null) {
            // Case 1: Order already placed -> Show menu item picker for existing order
            context.pushReplacementNamed(
              'menu-item-picker',
              extra: {
                'orderId': matchingOrder.orderId,
                'tableId': tableId,
                'tableName': matchingOrder.tableName,
              },
            );
          } else {
            // Case 2: Table not occupied -> Create new order for that table on scan
            context.pushReplacementNamed(
              'menu-item-picker',
              extra: {
                'tableId': tableId,
                'tableName': tableNameDisplay,
                'orderId': null,
              },
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        shared.DialogUtils.showAutoDismissDialog(
          context: context,
          title:
              context.tr(
                shared.LocaleKeys.commonError,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Error',
          descriptions: e.toString(),
        );
        setState(() {
          _isProcessing = false;
        });
        _scannerController.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          context.tr(
                shared.LocaleKeys.scanTableQrTooltip,
                track: shared.TrackConstants.tablePageTrack,
              ) ??
              'Scan Table QR Code',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => _scannerController.toggleTorch(),
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                final isOn = state.torchState == TorchState.on;
                return Icon(
                  isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: Colors.white,
                );
              },
            ),
          ),
          IconButton(
            onPressed: () => _scannerController.switchCamera(),
            icon: const Icon(
              Icons.cameraswitch_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),

          // Custom Scanner Overlay
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    spreadRadius: 2000,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                context.tr(
                      shared.LocaleKeys.scanQrCodeInstruction,
                      track: shared.TrackConstants.tablePageTrack,
                    ) ??
                    'Point camera at Table QR code to scan and manage order',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

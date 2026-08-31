import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../../../bloc/checkout_bloc.dart';
import '../../../../domain/entities/cart_item.dart';

class CheckoutBarcodeScannerDialog extends StatefulWidget {
  final CheckoutBloc checkoutBloc;

  const CheckoutBarcodeScannerDialog({
    super.key,
    required this.checkoutBloc,
  });

  @override
  State<CheckoutBarcodeScannerDialog> createState() =>
      _CheckoutBarcodeScannerDialogState();
}

class _CheckoutBarcodeScannerDialogState
    extends State<CheckoutBarcodeScannerDialog> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  final TextEditingController _manualInputController = TextEditingController();
  final FocusNode _manualInputFocusNode = FocusNode();

  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualInputController.dispose();
    _manualInputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final db = sl<CoozyDatabase>();
      final itemsWithVars = await db.menuItemsDao.getAllMenuItems();

      MenuItem? matchedItem;
      MenuItemVariation? matchedVariation;

      if (itemsWithVars != null) {
        for (final itemWithVar in itemsWithVars) {
          final item = itemWithVar.item;
          final variations = itemWithVar.variations;

          // 1. Check item direct payload / hashId / ID
          if (code == 'ITEM_${item.id}' ||
              code == item.hashId ||
              code == item.id.toString() ||
              code.toLowerCase() == item.name.toLowerCase()) {
            matchedItem = item;
            break;
          }

          // 2. Check variations
          for (final v in variations) {
            if (code == 'VAR_${v.id}' ||
                code == v.hashId ||
                code == v.id.toString() ||
                code.toLowerCase() == v.name?.toLowerCase()) {
              matchedItem = item;
              matchedVariation = v;
              break;
            }
          }

          if (matchedItem != null) break;
        }
      }

      if (matchedItem == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No item found for barcode "$code"';
        });
        return;
      }

      // Create CartItem
      final String itemIdStr =
          matchedVariation != null
              ? 'var_${matchedVariation.id}'
              : 'item_${matchedItem.id}';

      final String displayName =
          matchedVariation != null && matchedVariation.name?.isNotEmpty == true
              ? '${matchedItem.name} (${matchedVariation.name})'
              : matchedItem.name;

      final double unitPrice =
          matchedVariation?.sellingPrice ?? matchedItem.sellingPrice ?? 0.0;

      final cartItem = CartItem(
        id: itemIdStr,
        name: displayName,
        quantity: 1,
        unitPrice: unitPrice,
      );

      widget.checkoutBloc.add(CheckoutItemAdded(cartItem));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Added "$displayName" (${unitPrice.toStringAsFixed(2)})'),
            backgroundColor: Colors.green[800],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error processing barcode: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 650),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      color: theme.colorScheme.primary,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Scan Item Barcode',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 16),

            // Camera Scanner Box
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) {
                        final barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final code = barcodes.first.rawValue;
                          if (code != null && code.isNotEmpty) {
                            _processBarcode(code);
                          }
                        }
                      },
                    ),
                    // Reticle overlay
                    Container(
                      width: 200,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // Controls overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.flash_on_rounded, size: 20),
                            onPressed: () => _scannerController.toggleTorch(),
                          ),
                          const SizedBox(width: 6),
                          IconButton.filledTonal(
                            icon: const Icon(
                              Icons.cameraswitch_rounded,
                              size: 20,
                            ),
                            onPressed: () => _scannerController.switchCamera(),
                          ),
                        ],
                      ),
                    ),
                    if (_isProcessing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 16),
            Text(
              'Or enter barcode payload manually:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),

            // Manual Code Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualInputController,
                    focusNode: _manualInputFocusNode,
                    decoration: InputDecoration(
                      hintText: 'e.g. ITEM_15 or VAR_8',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (val) => _processBarcode(val),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed:
                      _isProcessing
                          ? null
                          : () => _processBarcode(_manualInputController.text),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

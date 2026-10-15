import 'package:equatable/equatable.dart';

/// Clean domain entity representing a detected USB thermal printer device,
/// avoiding direct dependencies on native FFI plugin types.
class UsbPrinterDevice extends Equatable {
  final String? name;
  final String? vendorId;
  final String? productId;

  const UsbPrinterDevice({
    this.name,
    this.vendorId,
    this.productId,
  });

  @override
  List<Object?> get props => [name, vendorId, productId];
}

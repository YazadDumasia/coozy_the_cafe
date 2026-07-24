import 'package:hashids2/hashids2.dart';

/// Generates unique hash IDs for invoices, inventory items, etc.
class HashIdGenerator {
  HashIdGenerator._();

  static final HashIds _invoiceHashIds = HashIds(
    salt: 'coozy_cafe_invoice_salt',
    minHashLength: 8,
    alphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
  );

  static final HashIds _inventoryHashIds = HashIds(
    salt: 'coozy_cafe_inventory_salt',
    minHashLength: 6,
    alphabet: 'abcdefghijklmnopqrstuvwxyz1234567890',
  );

  static final HashIds _purchaseHashIds = HashIds(
    salt: 'coozy_cafe_purchase_salt',
    minHashLength: 6,
    alphabet: 'abcdefghijklmnopqrstuvwxyz1234567890',
  );

  static final HashIds _paymentModeHashIds = HashIds(
    salt: 'coozy_cafe_payment_mode_salt',
    minHashLength: 6,
    alphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
  );

  /// Generates a unique invoice hash ID from an integer ID + timestamp.
  static String generateInvoiceHashId(int id) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'INV-${_invoiceHashIds.encode([id, timestamp % 100000])}';
  }

  /// Generates a unique inventory hash ID.
  static String generateInventoryHashId(int id) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'INVT-${_inventoryHashIds.encode([id, timestamp % 100000])}';
  }

  /// Generates a unique purchase hash ID.
  static String generatePurchaseHashId(int id) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'PUR-${_purchaseHashIds.encode([id, timestamp % 100000])}';
  }

  /// Generates a unique payment mode hash ID.
  static String generatePaymentModeHashId(int id) {
    return 'PM-${_paymentModeHashIds.encode([id])}';
  }

  /// Decodes an invoice hash ID back to its components.
  static List<int> decodeInvoiceHashId(String hashId) {
    final encoded = hashId.replaceFirst('INV-', '');
    return _invoiceHashIds.decode(encoded);
  }
}

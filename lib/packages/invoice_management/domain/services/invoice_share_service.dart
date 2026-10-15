import 'package:shared_preferences/shared_preferences.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../entities/invoice_management_entity.dart';

/// Service responsible for generating formatted text messages for sharing invoices
/// via SMS, WhatsApp, and clipboard. Supports placeholders and user customizations.
class InvoiceShareService {
  InvoiceShareService._();

  static final InvoiceShareService instance = InvoiceShareService._();

  /// Available dynamic placeholder tokens that can be inserted into the custom template.
  static const String tokenCafeName = '{cafe_name}';
  static const String tokenReceiptNo = '{receipt_no}';
  static const String tokenDate = '{date}';
  static const String tokenTable = '{table}';
  static const String tokenCustomerName = '{customer_name}';
  static const String tokenCustomerPhone = '{customer_phone}';
  static const String tokenItems = '{items}';
  static const String tokenSubtotal = '{subtotal}';
  static const String tokenDiscount = '{discount}';
  static const String tokenTax = '{tax}';
  static const String tokenTotal = '{total}';
  static const String tokenPaymentMethod = '{payment_method}';
  static const String tokenLink = '{link}';

  /// List of supported tokens with user-friendly descriptions.
  static const List<Map<String, String>> supportedTokens = [
    {'token': tokenCafeName, 'label': 'Cafe Name'},
    {'token': tokenReceiptNo, 'label': 'Receipt No'},
    {'token': tokenDate, 'label': 'Date & Time'},
    {'token': tokenTable, 'label': 'Table'},
    {'token': tokenCustomerName, 'label': 'Customer'},
    {'token': tokenCustomerPhone, 'label': 'Phone'},
    {'token': tokenItems, 'label': 'Item Breakdown'},
    {'token': tokenSubtotal, 'label': 'Subtotal'},
    {'token': tokenDiscount, 'label': 'Discount'},
    {'token': tokenTax, 'label': 'Tax'},
    {'token': tokenTotal, 'label': 'Grand Total'},
    {'token': tokenPaymentMethod, 'label': 'Payment Mode'},
    {'token': tokenLink, 'label': 'Custom Link / URL'},
  ];

  /// The standard default template reproducing the exact original invoice summary layout.
  static const String defaultTemplate =
      'COOZY THE CAFE - INVOICE\n'
      'Receipt No: {receipt_no}\n'
      'Date: {date}\n'
      '{table}'
      '----------------------\n'
      '{items}\n'
      '----------------------\n'
      'Subtotal: {subtotal}\n'
      '{discount}'
      '{tax}'
      'Grand Total: {total}\n'
      'Payment: {payment_method}\n'
      'Thank you for visiting Coozy The Cafe!\n'
      '{link}';

  /// Retrieves the saved template from SharedPreferences, or returns [defaultTemplate].
  Future<String> getTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(shared.PreferencesKeys.invoiceShareMessageTemplate.name);
    if (saved != null && saved.trim().isNotEmpty) {
      return saved;
    }
    return defaultTemplate;
  }

  /// Retrieves the custom review / website link from SharedPreferences.
  Future<String> getCustomLink() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(shared.PreferencesKeys.invoiceShareCustomLink.name)?.trim() ?? '';
  }

  /// Saves the custom template to SharedPreferences.
  Future<void> saveTemplate(String template) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = template.trim();
    if (trimmed.isEmpty || trimmed == defaultTemplate.trim()) {
      await prefs.remove(shared.PreferencesKeys.invoiceShareMessageTemplate.name);
    } else {
      await prefs.setString(shared.PreferencesKeys.invoiceShareMessageTemplate.name, template);
    }
  }

  /// Saves the custom link to SharedPreferences.
  Future<void> saveCustomLink(String link) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = link.trim();
    if (trimmed.isEmpty) {
      await prefs.remove(shared.PreferencesKeys.invoiceShareCustomLink.name);
    } else {
      await prefs.setString(shared.PreferencesKeys.invoiceShareCustomLink.name, trimmed);
    }
  }

  /// Resets the template and link back to defaults.
  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(shared.PreferencesKeys.invoiceShareMessageTemplate.name);
    await prefs.remove(shared.PreferencesKeys.invoiceShareCustomLink.name);
  }

  /// Formats the items block for the invoice.
  String formatItemsBlock(List<InvoiceItemEntity> items) {
    final buffer = StringBuffer();
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.write('${item.itemName} x${item.quantity} = ${core.CurrencyFormatter.format(value: item.totalPrice)}');
      if (i < items.length - 1) {
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  /// Resolves an invoice into a complete formatted string using the configured or default template.
  Future<String> buildShareMessage(InvoiceDetailsEntity details) async {
    final template = await getTemplate();
    final customLink = await getCustomLink();
    return formatMessageWithTemplate(
      details: details,
      template: template,
      customLink: customLink,
    );
  }

  /// Synchronously formats an invoice with a provided template and custom link.
  String formatMessageWithTemplate({
    required InvoiceDetailsEntity details,
    required String template,
    String? customLink,
  }) {
    final inv = details.invoice;
    final receiptNo = inv.hashId.isNotEmpty ? inv.hashId : 'MD-${inv.id}';
    final dateStr = inv.createdDate != null
        ? (core.DateUtil.localFormat(inv.createdDate, 'dd MMM yyyy - hh:mm a') ?? inv.createdDate!)
        : '';
    final tableLine = (details.tableName != null && details.tableName!.trim().isNotEmpty)
        ? 'Table: ${details.tableName!.trim()}\n'
        : '';
    final customerName = inv.customerName?.trim() ?? 'Guest';
    final customerPhone = inv.phoneNumber?.trim() ?? '';
    final itemsBlock = formatItemsBlock(details.items);
    final subtotalStr = core.CurrencyFormatter.format(value: inv.totalCost);
    final discountLine = inv.discountAmount > 0
        ? 'Discount: -${core.CurrencyFormatter.format(value: inv.discountAmount)}\n'
        : '';
    final taxLine = inv.taxCost > 0
        ? 'Tax: +${core.CurrencyFormatter.format(value: inv.taxCost)}\n'
        : '';
    final totalStr = core.CurrencyFormatter.format(value: inv.netPaymentAmount);
    final paymentMethod = inv.paymentMethodName ?? 'Cash';
    final linkLine = (customLink != null && customLink.trim().isNotEmpty)
        ? '\nView/Review us: ${customLink.trim()}'
        : '';

    var result = template;
    result = result.replaceAll(tokenCafeName, 'Coozy The Cafe');
    result = result.replaceAll(tokenReceiptNo, receiptNo);
    result = result.replaceAll(tokenDate, dateStr);
    result = result.replaceAll(tokenTable, tableLine);
    result = result.replaceAll(tokenCustomerName, customerName);
    result = result.replaceAll(tokenCustomerPhone, customerPhone);
    result = result.replaceAll(tokenItems, itemsBlock);
    result = result.replaceAll(tokenSubtotal, subtotalStr);
    result = result.replaceAll(tokenDiscount, discountLine);
    result = result.replaceAll(tokenTax, taxLine);
    result = result.replaceAll(tokenTotal, totalStr);
    result = result.replaceAll(tokenPaymentMethod, paymentMethod);
    result = result.replaceAll(tokenLink, linkLine);

    // Clean up potential excessive double blank lines from empty conditional tokens
    return result.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }
}

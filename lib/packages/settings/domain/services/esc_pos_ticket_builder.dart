import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/invoice_management/domain/entities/invoice_management_entity.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/domain/entities/kitchen_order_entity.dart';

import '../../domain/entities/thermal_printer_config.dart';

/// Builder utility that generates raw ESC/POS command byte buffers
/// for Customer Invoices and Kitchen Order Tickets (KOT).
class EscPosTicketBuilder {
  EscPosTicketBuilder._();

  /// Builds ESC/POS bytes for a Customer Receipt Invoice
  static Future<List<int>> buildCustomerReceiptBytes({
    required InvoiceDetailsEntity details,
    required ThermalPaperSize paperSize,
    String? cafeName,
    String? cafeAddress,
    String? cafePhone,
    String? footerMessage,
  }) async {
    final finalCafeName = cafeName ?? 'Coozy The Cafe';
    final finalCafeAddress = cafeAddress ??
        'G-24, Marvella business hub, Adajan pal, Pal RTO BRTS Rd, Surat, Gujarat 394510';
    final finalCafePhone = cafePhone ?? '+91 9974776639';
    final paper = paperSize == ThermalPaperSize.mm58
        ? PaperSize.mm58
        : PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final generator = Generator(paper, profile);

    List<int> bytes = [];
    bytes += generator.reset();

    // 1. Header
    bytes += generator.text(
      finalCafeName,
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    if (finalCafeAddress.isNotEmpty) {
      bytes += generator.text(
        finalCafeAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (finalCafePhone.isNotEmpty) {
      bytes += generator.text(
        'Tel: $finalCafePhone',
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.feed(1);
    bytes += generator.text(
      'TAX INVOICE / RECEIPT',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.hr();

    // 2. Metadata (Invoice No, Date, Table, Customer)
    final invoice = details.invoice;
    final String invoiceNumber = invoice.hashId.isNotEmpty
        ? invoice.hashId
        : '#INV-${invoice.id}';
    final String dateStr =
        invoice.createdDate != null && invoice.createdDate!.isNotEmpty
        ? (core.DateUtil.localFormat(invoice.createdDate, 'dd/MM/yyyy HH:mm') ??
              invoice.createdDate!)
        : '';

    bytes += generator.row([
      PosColumn(text: 'Inv No:', width: 4, styles: const PosStyles(bold: true)),
      PosColumn(text: invoiceNumber, width: 8),
    ]);
    if (dateStr.isNotEmpty) {
      bytes += generator.row([
        PosColumn(text: 'Date:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: dateStr, width: 8),
      ]);
    }
    if (details.tableName != null && details.tableName!.isNotEmpty) {
      bytes += generator.row([
        PosColumn(
          text: 'Table:',
          width: 4,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(text: details.tableName!, width: 8),
      ]);
    }
    if (invoice.customerName != null && invoice.customerName!.isNotEmpty) {
      bytes += generator.row([
        PosColumn(
          text: 'Customer:',
          width: 4,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(text: invoice.customerName!, width: 8),
      ]);
    }

    bytes += generator.hr();

    // 3. Items Table Header
    bytes += generator.row([
      PosColumn(text: 'Item', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'Price',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.hr(ch: '-');

    // 4. Line Items
    for (final item in details.items) {
      bytes += generator.row([
        PosColumn(text: item.itemName, width: 6),
        PosColumn(
          text: '${item.quantity}',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: item.totalPrice.toStringAsFixed(2),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr(ch: '-');

    // 5. Financial Summary
    bytes += generator.row([
      PosColumn(text: 'Subtotal:', width: 6),
      PosColumn(
        text: invoice.totalCost.toStringAsFixed(2),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (invoice.discountAmount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Discount:', width: 6),
        PosColumn(
          text: '-${invoice.discountAmount.toStringAsFixed(2)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if (invoice.taxCost > 0) {
      bytes += generator.row([
        PosColumn(text: 'Tax (${invoice.taxPercentage}%):', width: 6),
        PosColumn(
          text: invoice.taxCost.toStringAsFixed(2),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL AMOUNT:',
        width: 6,
        styles: const PosStyles(bold: true, height: PosTextSize.size1),
      ),
      PosColumn(
        text: invoice.netPaymentAmount.toStringAsFixed(2),
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size1,
        ),
      ),
    ]);

    if (invoice.paymentMethodName != null &&
        invoice.paymentMethodName!.isNotEmpty) {
      bytes += generator.row([
        PosColumn(text: 'Paid via:', width: 6),
        PosColumn(
          text: invoice.paymentMethodName!,
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.feed(1);
    if (footerMessage != null && footerMessage.trim().isNotEmpty) {
      bytes += generator.text(
        footerMessage.trim(),
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
    } else {
      bytes += generator.text(
        'Thank you for visiting!',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.text(
        'Please visit again',
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  /// Builds ESC/POS bytes for a Kitchen Station KOT ticket
  static Future<List<int>> buildKitchenTicketBytes({
    required KitchenOrderEntity order,
    required ThermalPaperSize paperSize,
    String? serverName,
    String? remarks,
  }) async {
    final paper = paperSize == ThermalPaperSize.mm58
        ? PaperSize.mm58
        : PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final generator = Generator(paper, profile);

    List<int> bytes = [];
    bytes += generator.reset();

    // 1. KOT Header
    bytes += generator.text(
      '*** KITCHEN ORDER TICKET ***',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);

    // 2. Big Table / Order Identification
    final String tableName =
        order.tableNameText != null && order.tableNameText!.isNotEmpty
        ? order.tableNameText!
        : (order.orderType?.toUpperCase() ?? 'TAKEAWAY');

    bytes += generator.text(
      tableName,
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );

    bytes += generator.hr();

    // 3. Ticket Meta Info
    bytes += generator.row([
      PosColumn(
        text: 'Ticket #:',
        width: 4,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(text: '${order.id}', width: 8),
    ]);

    final String dateStr =
        order.creationDate != null && order.creationDate!.isNotEmpty
        ? (core.DateUtil.localFormat(order.creationDate, 'dd/MM/yyyy HH:mm') ??
              order.creationDate!)
        : '';
    if (dateStr.isNotEmpty) {
      bytes += generator.row([
        PosColumn(text: 'Time:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: dateStr, width: 8),
      ]);
    }
    if (order.orderType != null && order.orderType!.isNotEmpty) {
      bytes += generator.row([
        PosColumn(text: 'Type:', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: order.orderType!.toUpperCase(), width: 8),
      ]);
    }
    if (serverName != null && serverName.isNotEmpty) {
      bytes += generator.row([
        PosColumn(
          text: 'Server:',
          width: 4,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(text: serverName, width: 8),
      ]);
    }

    bytes += generator.hr();

    // 4. Items Table Header
    bytes += generator.row([
      PosColumn(text: 'QTY', width: 3, styles: const PosStyles(bold: true)),
      PosColumn(
        text: 'ITEM NAME',
        width: 9,
        styles: const PosStyles(bold: true),
      ),
    ]);
    bytes += generator.hr(ch: '-');

    // 5. Kitchen Items
    for (final item in order.items) {
      bytes += generator.row([
        PosColumn(
          text: '${item.quantity}x',
          width: 3,
          styles: const PosStyles(
            bold: true,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
        PosColumn(
          text: item.itemName,
          width: 9,
          styles: const PosStyles(
            bold: true,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
      ]);

      // Modifiers / Variations
      if (item.variationQuantity != null &&
          item.variationQuantity!.isNotEmpty) {
        bytes += generator.row([
          PosColumn(text: '', width: 3),
          PosColumn(
            text: ' > ${item.variationQuantity} ${item.variationUnit ?? ''}'
                .trim(),
            width: 9,
          ),
        ]);
      }

      // Remarks / Instructions
      if (item.remarks != null && item.remarks!.isNotEmpty) {
        bytes += generator.row([
          PosColumn(text: '', width: 3),
          PosColumn(
            text: ' * NOTE: ${item.remarks}',
            width: 9,
            styles: const PosStyles(bold: true),
          ),
        ]);
      }
    }

    // 6. Global Remarks
    if (remarks != null && remarks.isNotEmpty) {
      bytes += generator.hr(ch: '-');
      bytes += generator.text(
        'ORDER NOTE: $remarks',
        styles: const PosStyles(bold: true),
      );
    }

    bytes += generator.hr();
    bytes += generator.feed(1);
    bytes += generator.text(
      '--- END OF ORDER ---',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}

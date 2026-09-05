import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import '../../../../domain/entities/invoice_management_entity.dart';

class InvoiceCardWidget extends StatelessWidget {
  final InvoiceEntity invoice;
  final VoidCallback onTap;

  const InvoiceCardWidget({
    super.key,
    required this.invoice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isUpi = (invoice.paymentMethodName ?? '')
        .toLowerCase()
        .contains('upi');
    final methodText = invoice.paymentMethodName ?? 'Cash';
    final receiptTitle = invoice.hashId.isNotEmpty
        ? invoice.hashId
        : 'MD-${invoice.id}';

    final createdDateStr = invoice.createdDate != null
        ? core.DateUtil.dateToString(
            DateTime.tryParse(invoice.createdDate!) ?? DateTime.now(),
            'dd MMM yyyy - hh:mm a',
          ) ?? ''
        : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Icon
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: isUpi
                    ? Icon(Icons.qr_code, color: colorScheme.primary, size: 28)
                    : Icon(Icons.payments, color: Colors.green, size: 28),
              ),
              const SizedBox(width: 12),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiptTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'by $methodText',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdDateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Price
              Text(
                '₹${invoice.netPaymentAmount.toStringAsFixed(0)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

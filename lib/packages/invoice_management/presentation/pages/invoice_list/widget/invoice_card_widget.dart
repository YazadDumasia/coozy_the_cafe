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

  IconData _getPaymentIcon(String? rawMethod) {
    final method = (rawMethod ?? '').trim().toLowerCase();
    return switch (method) {
      'upi' || 'qr' || 'qr code' || 'online' => Icons.qr_code,
      'card' || 'debit card' || 'credit card' => Icons.credit_card,
      'bank' || 'net banking' || 'netbanking' || 'bank transfer' => Icons.account_balance,
      'wallet' || 'e-wallet' => Icons.account_balance_wallet,
      'cash' => Icons.payments,
      'cheque' || 'check' => Icons.receipt_long,
      'gift card' || 'voucher' => Icons.card_giftcard,
      _ when method.contains('upi') || method.contains('qr') || method.contains('online') => Icons.qr_code,
      _ when method.contains('card') || method.contains('debit') || method.contains('credit') => Icons.credit_card,
      _ when method.contains('bank') || method.contains('transfer') => Icons.account_balance,
      _ when method.contains('wallet') => Icons.account_balance_wallet,
      _ => Icons.payment,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final rawPaymentMethod = invoice.paymentMethodName?.toString() ?? '';
    final methodText = rawPaymentMethod.trim().isNotEmpty ? rawPaymentMethod : 'Cash';
    final paymentIcon = _getPaymentIcon(rawPaymentMethod);

    final hashIdVal = invoice.hashId;
    final receiptTitle =
        hashIdVal.isNotEmpty ? hashIdVal : 'MD-${invoice.id}';

    final createdDateStr = invoice.createdDate != null
        ? core.DateUtil.dateToString(
            DateTime.tryParse(invoice.createdDate!) ?? DateTime.now(),
            'dd MMM yyyy - hh:mm a',
          ) ?? ''
        : '';
    final netAmount = invoice.netPaymentAmount;

    final hasCustomerName = invoice.customerName != null && invoice.customerName!.trim().isNotEmpty;
    final hasPhone = invoice.phoneNumber != null && invoice.phoneNumber!.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      paymentIcon,
                      color: paymentIcon == Icons.payments ? Colors.green : colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title & Order badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                receiptTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (invoice.orderId != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Order #${invoice.orderId}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              methodText,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (createdDateStr.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  createdDateStr,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasCustomerName || hasPhone) ...[
                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasCustomerName ? invoice.customerName!.trim() : 'Customer',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasPhone) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${invoice.phoneNumber!.trim()})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Payment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    core.CurrencyFormatter.format(value: netAmount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

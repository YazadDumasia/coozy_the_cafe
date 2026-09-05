import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/order_management_bloc.dart';
import '../../../domain/entities/order_management_entity.dart';
import 'order_info_screen_actions.dart';

class OrderInfoScreen extends StatefulWidget {
  final int orderId;
  final OrderManagementEntity? initialOrder;

  const OrderInfoScreen({super.key, required this.orderId, this.initialOrder});

  @override
  State<OrderInfoScreen> createState() => _OrderInfoScreenState();
}

class _OrderInfoScreenState extends State<OrderInfoScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialOrder == null) {
      context.read<OrderManagementBloc>().add(
        LoadOrderDetailsEvent(widget.orderId),
      );
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'inprogress':
      case 'in_progress':
      case 'inpreparation':
        return Colors.orange;
      case 'cancelled':
      case 'canceled':
        return theme.colorScheme.error;
      case 'neworder':
      case 'new':
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr(
                  shared.LocaleKeys.orderManagementOrderInfoAppbarTitle,
                  track: shared.TrackConstants.orderManagementPageTrack,
                ) ??
                'Order Information',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share Order',
              onPressed: () {
                OrderInfoScreenActions.onShareOrder(
                  context,
                  orderId: widget.orderId,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: context.tr(
                    shared.LocaleKeys.orderManagementInvoiceInfoButton,
                    track: shared.TrackConstants.orderManagementPageTrack,
                  ) ??
                  'Invoice Info',
              onPressed: () {
                OrderInfoScreenActions.onInvoiceInfo(
                  context,
                  orderId: widget.orderId,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<OrderManagementBloc, OrderManagementState>(
          builder: (context, state) {
            OrderManagementEntity? order = widget.initialOrder;
            if (state is OrderManagementLoadedState &&
                state.selectedOrderDetails != null &&
                state.selectedOrderDetails!.id == widget.orderId) {
              order = state.selectedOrderDetails;
            }

            if (order == null) {
              if (state is OrderManagementLoadedState &&
                  state.isLoadingDetails) {
                return const shared.LoadingPage();
              }
              if (state is OrderManagementErrorState) {
                return shared.ErrorPage(
                  errorMsg: state.message,
                  onPressedRetryButton: () {
                    context.read<OrderManagementBloc>().add(
                      LoadOrderDetailsEvent(widget.orderId),
                    );
                  },
                );
              }

              return const shared.LoadingPage();
            }

            final statusColor = _getStatusColor(context, order.status);
            final creationFormatted = order.creationDate != null
                ? DateUtil.localFormat(
                        order.creationDate,
                        DateUtil.dateFormat3,
                      ) ??
                      order.creationDate!
                : 'N/A';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: $creationFormatted',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Invoice Info Button
                ElevatedButton.icon(
                  onPressed: () {
                    OrderInfoScreenActions.onInvoiceInfo(
                      context,
                      orderId: widget.orderId,
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: Text(
                    context.tr(
                          shared.LocaleKeys.orderManagementInvoiceInfoButton,
                          track: shared.TrackConstants.orderManagementPageTrack,
                        ) ??
                        'Invoice Info',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 3,
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Order Meta Details
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildDetailRow(
                          context,
                          icon: Icons.table_restaurant,
                          label: 'Table',
                          value: order.tableNameText ?? 'N/A',
                        ),
                        _buildDetailRow(
                          context,
                          icon: Icons.room_service,
                          label: 'Order Type',
                          value: order.orderType ?? 'Dine-In',
                        ),
                        if (order.customerName != null &&
                            order.customerName!.isNotEmpty)
                          _buildDetailRow(
                            context,
                            icon: Icons.person,
                            label: 'Customer',
                            value: order.customerName!,
                          ),
                        if (order.phoneNumber != null &&
                            order.phoneNumber!.isNotEmpty)
                          _buildDetailRow(
                            context,
                            icon: Icons.phone,
                            label: 'Phone',
                            value: order.phoneNumber!,
                          ),
                        _buildDetailRow(
                          context,
                          icon: Icons.payment,
                          label: 'Payment Method',
                          value:
                              (order.paymentMethodName != null &&
                                  order.paymentMethodName!.isNotEmpty)
                              ? order.paymentMethodName!
                              : 'Pending / Not Selected',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Items Section
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ordered Items (${order.items.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        if (order.items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No items attached to this order',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        else
                          ...order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.itemName ?? 'Item #${item.id}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          'Qty: ${item.quantity} x ${CurrencyFormatter.format(value: item.sellingPrice)}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(
                                      value: item.subTotal,
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(
                                value: order.totalAmount,
                              ),
                              style: theme.textTheme.headlineSmall?.copyWith(
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
                const SizedBox(height: 16),

                // Billing & Financial Breakdown Card (ExpansionTile)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                    collapsedShape: const RoundedRectangleBorder(
                      side: BorderSide.none,
                    ),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      'Billing & Payment Breakdown',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Grand Total: ${CurrencyFormatter.format(value: order.totalAmount)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            const Divider(height: 1),
                            _buildBreakdownRow(
                              context,
                              label: 'Payment Method',
                              value:
                                  (order.paymentMethodName != null &&
                                      order.paymentMethodName!.isNotEmpty)
                                  ? order.paymentMethodName!
                                  : 'Pending / Not Selected',
                              isBold: true,
                            ),
                            _buildBreakdownRow(
                              context,
                              label: 'Subtotal',
                              value: CurrencyFormatter.format(
                                value: order.subtotalAmount > 0
                                    ? order.subtotalAmount
                                    : order.items.fold<double>(
                                        0.0,
                                        (s, i) => s + i.subTotal,
                                      ),
                              ),
                            ),

                            // Render Individual Taxes if taxDetailsList is available
                            if (order.taxDetailsList.isNotEmpty) ...[
                              ...order.taxDetailsList.map((tax) {
                                final name = tax['name'] ?? 'Tax';
                                final rate = tax['ratePercent'] != null
                                    ? '${tax['ratePercent']}%'
                                    : '';
                                final amt =
                                    (tax['amount'] as num?)?.toDouble() ?? 0.0;
                                if (amt <= 0) return const SizedBox.shrink();
                                final labelText = rate.isNotEmpty
                                    ? '$name ($rate)'
                                    : '$name';
                                return _buildBreakdownRow(
                                  context,
                                  label: labelText,
                                  value:
                                      '+${CurrencyFormatter.format(value: amt)}',
                                  valueColor: colorScheme.onSurfaceVariant,
                                );
                              }),
                            ] else if (order.taxAmount > 0) ...[
                              _buildBreakdownRow(
                                context,
                                label: order.taxPercentage > 0
                                    ? 'Tax (${order.taxPercentage}%)'
                                    : 'Tax',
                                value:
                                    '+${CurrencyFormatter.format(value: order.taxAmount)}',
                                valueColor: colorScheme.onSurfaceVariant,
                              ),
                            ],

                            // Render Individual Discounts if discountDetailsList is available
                            if (order.discountDetailsList.isNotEmpty) ...[
                              ...order.discountDetailsList.map((disc) {
                                final name = disc['name'] ?? 'Discount';
                                final amt =
                                    (disc['amount'] as num?)?.toDouble() ?? 0.0;
                                if (amt <= 0) return const SizedBox.shrink();
                                return _buildBreakdownRow(
                                  context,
                                  label: name,
                                  value:
                                      '-${CurrencyFormatter.format(value: amt)}',
                                  valueColor: Colors.red.shade700,
                                );
                              }),
                            ] else if (order.discountAmount > 0) ...[
                              _buildBreakdownRow(
                                context,
                                label: 'Discount',
                                value:
                                    '-${CurrencyFormatter.format(value: order.discountAmount)}',
                                valueColor: Colors.red.shade700,
                              ),
                            ],

                            // Render Individual Charges if chargeDetailsList is available
                            if (order.chargeDetailsList.isNotEmpty) ...[
                              ...order.chargeDetailsList.map((chg) {
                                final name = chg['name'] ?? 'Other Charge';
                                final amt =
                                    (chg['amount'] as num?)?.toDouble() ?? 0.0;
                                if (amt <= 0) return const SizedBox.shrink();
                                return _buildBreakdownRow(
                                  context,
                                  label: name,
                                  value:
                                      '+${CurrencyFormatter.format(value: amt)}',
                                  valueColor: colorScheme.onSurfaceVariant,
                                );
                              }),
                            ] else if (order.otherChargesAmount > 0) ...[
                              _buildBreakdownRow(
                                context,
                                label: 'Other Charges',
                                value:
                                    '+${CurrencyFormatter.format(value: order.otherChargesAmount)}',
                                valueColor: colorScheme.onSurfaceVariant,
                              ),
                            ],

                            const Divider(),
                            _buildBreakdownRow(
                              context,
                              label: 'Grand Total',
                              value: CurrencyFormatter.format(
                                value: order.totalAmount,
                              ),
                              isBold: true,
                              fontSize: 16,
                              valueColor: colorScheme.primary,
                            ),
                            if (order.cashReceivedAmount > 0) ...[
                              const SizedBox(height: 4),
                              _buildBreakdownRow(
                                context,
                                label: 'Cash Received',
                                value: CurrencyFormatter.format(
                                  value: order.cashReceivedAmount,
                                ),
                                valueColor: colorScheme.onSurfaceVariant,
                              ),
                              if (order.changeAmount > 0)
                                _buildBreakdownRow(
                                  context,
                                  label: 'Change Given',
                                  value: CurrencyFormatter.format(
                                    value: order.changeAmount,
                                  ),
                                  valueColor: colorScheme.secondary,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                if (order.status != 'completed' && order.status != 'cancelled')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            OrderInfoScreenActions.onUpdateStatus(
                              context,
                              orderId: order!.id,
                              status: 'cancelled',
                            );
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Cancel Order'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(color: colorScheme.error),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            OrderInfoScreenActions.onUpdateStatus(
                              context,
                              orderId: order!.id,
                              status: 'completed',
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Mark Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isBold = false,
    double? fontSize,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
              color: isBold
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: fontSize,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

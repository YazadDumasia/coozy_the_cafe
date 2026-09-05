import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/invoice_management_bloc.dart';
import '../../../domain/entities/invoice_management_entity.dart';
import 'invoice_detail_screen_actions.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final int invoiceId;
  final InvoiceEntity? initialInvoice;
  final bool fromCheckout;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
    this.initialInvoice,
    this.fromCheckout = false,
  });

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InvoiceManagementBloc>().add(
          LoadInvoiceDetailsEvent(widget.invoiceId),
        );
      }
    });
  }

  void _handleBackNavigation(BuildContext context) {
    if (widget.fromCheckout) {
      context.go(core.AppRoutePath.homeRoute);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(core.AppRoutePath.homeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation(context);
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handleBackNavigation(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => InvoiceDetailScreenActions.onShare(context),
              ),
              IconButton(
                icon: const Icon(Icons.sms_outlined),
                onPressed: () => InvoiceDetailScreenActions.onSendSms(context),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () => InvoiceDetailScreenActions.onWhatsApp(context),
              ),
              IconButton(
                icon: const Icon(Icons.file_download_outlined),
                onPressed: () => InvoiceDetailScreenActions.onDownload(context),
              ),
              IconButton(
                icon: const Icon(Icons.print_outlined),
                onPressed: () => InvoiceDetailScreenActions.onPrint(context),
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          body: BlocBuilder<InvoiceManagementBloc, InvoiceManagementState>(
            builder: (context, state) {
              InvoiceDetailsEntity? details;
              if (state is InvoiceManagementLoadedState) {
                details = state.selectedInvoiceDetails;
              }

              if (details == null &&
                  state is InvoiceManagementLoadedState &&
                  state.isLoadingDetails) {
                return const shared.LoadingPage();
              }

              final inv =
                  details?.invoice ??
                  widget.initialInvoice ??
                  InvoiceEntity(
                    id: widget.invoiceId,
                    hashId: 'MD-11788',
                    netPaymentAmount: 640.0,
                    paymentMethodName: 'UPI / BHIM',
                    createdDate: DateTime.now().toIso8601String(),
                  );

              final items = details?.items ?? [];
              final totalUnits =
                  details?.totalUnits ??
                  items.fold<int>(0, (s, i) => s + i.quantity);
              final totalTypes = details?.totalItemTypes ?? items.length;

              final createdDateStr = inv.createdDate != null
                  ? core.DateUtil.dateToString(
                          DateTime.tryParse(inv.createdDate!) ?? DateTime.now(),
                          'dd Aug yyyy - hh:mm a',
                        ) ??
                        ''
                  : '';

              return Column(
                children: [
                  Container(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: details != null
                                ? () => InvoiceDetailScreenActions.onReturn(
                                    context,
                                    details!,
                                  )
                                : null,
                            child: Text(
                              context.tr(
                                    shared.LocaleKeys.invoiceActionReturn,
                                    track:
                                        shared.TrackConstants.invoicePageTrack,
                                  ) ??
                                  'RETURN',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: () =>
                                InvoiceDetailScreenActions.onDelete(
                                  context,
                                  inv.id,
                                ),
                            child: Text(
                              context.tr(
                                    shared.LocaleKeys.invoiceActionDelete,
                                    track:
                                        shared.TrackConstants.invoicePageTrack,
                                  ) ??
                                  'DELETE',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: details != null
                                ? () => InvoiceDetailScreenActions.onEdit(
                                    context,
                                    details!,
                                  )
                                : null,
                            child: Text(
                              context.tr(
                                    shared.LocaleKeys.invoiceActionEdit,
                                    track:
                                        shared.TrackConstants.invoicePageTrack,
                                  ) ??
                                  'EDIT',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: const Color(0xFF6D4C41),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.free_breakfast,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  Text(
                                    'COOZY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'COOZY THE CAFE',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Shop 24, Marvella business hub, pal adajan',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '+919725002491',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const Divider(height: 24),
                            Text(
                              'Receipt# ${inv.hashId.isNotEmpty ? inv.hashId : 'MD-${inv.id}'} | TABLE 5',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Date : $createdDateStr',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              color: Colors.grey.shade100,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              child: Row(
                                children: const [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'P Mode',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'I#',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'U#',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Amount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      inv.paymentMethodName ?? 'Cash',
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '$totalTypes',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '$totalUnits',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '₹${inv.netPaymentAmount.toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              color: Colors.grey.shade100,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              child: Row(
                                children: const [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Name',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Price',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Qty',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              addAutomaticKeepAlives: false,
                              addRepaintBoundaries: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.isEmpty ? 1 : items.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, idx) {
                                if (items.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 8,
                                    ),
                                    child: Text('No items in receipt'),
                                  );
                                }
                                final item = items[idx];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(item.itemName),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '₹${item.unitPrice.toStringAsFixed(2)}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${item.quantity}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '₹${item.totalPrice.toStringAsFixed(2)}',
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 24, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text('₹${inv.totalCost.toStringAsFixed(2)}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Grand Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '₹${inv.netPaymentAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Cash Received'),
                                Text(
                                  '₹${(inv.cashReceived ?? inv.netPaymentAmount).toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Change Amount'),
                                Text(
                                  '₹${(inv.changeAmount ?? 0.0).toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              context.tr(
                                    shared.LocaleKeys.invoiceFooterThankYou,
                                    track:
                                        shared.TrackConstants.invoicePageTrack,
                                  ) ??
                                  'Thank You , Visit Again.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr(
                                    shared.LocaleKeys.invoiceFooterPoweredBy,
                                    track:
                                        shared.TrackConstants.invoicePageTrack,
                                  ) ??
                                  'Powered By Restokeep',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

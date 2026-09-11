import 'dart:convert';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/invoice_management_bloc.dart';
import '../../../domain/entities/invoice_management_entity.dart';
import 'invoice_detail_screen_actions.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final int invoiceId;
  final String? hashId;
  final String? orderHashId;
  final InvoiceEntity? initialInvoice;
  final bool fromCheckout;

  const InvoiceDetailScreen({
    super.key,
    this.invoiceId = 0,
    this.hashId,
    this.orderHashId,
    this.initialInvoice,
    this.fromCheckout = false,
  }) : assert(
          invoiceId != 0 || hashId != null || orderHashId != null,
          'Either invoiceId, hashId, or orderHashId must be provided',
        );

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  bool _hasUpdated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.hashId != null) {
          // Load by invoice's own hashId
          context.read<InvoiceManagementBloc>().add(
            LoadInvoiceDetailsByHashIdEvent(widget.hashId!),
          );
        } else if (widget.orderHashId != null) {
          // Load by linked order's hashId
          context.read<InvoiceManagementBloc>().add(
            LoadInvoiceDetailsByOrderHashIdEvent(widget.orderHashId!),
          );
        } else {
          // Load by integer invoiceId
          context.read<InvoiceManagementBloc>().add(
            LoadInvoiceDetailsEvent(widget.invoiceId),
          );
        }
      }
    });
  }

  void _handleBackNavigation(BuildContext context) {
    if (widget.fromCheckout) {
      context.go(core.AppRoutePath.homeRoute);
    } else if (context.canPop()) {
      context.pop(_hasUpdated);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(_hasUpdated);
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
            title: Text(
              context.tr(
                    shared.LocaleKeys.invoiceDetailTitle,
                    track:
                        shared.TrackConstants.invoicePageTrack,
                  ) ??
                  'Invoice Details',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
                icon:  Icon(FontAwesomeIcons.whatsapp.data),
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

              final createdDateStr = inv.createdDate != null
                  ? (core.DateUtil.localFormat(
                          inv.createdDate,
                          'dd MMM yyyy - hh:mm a',
                        ) ??
                        '')
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
                                  fromCheckout: widget.fromCheckout,
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
                                ? () async {
                                    final updated =
                                        await InvoiceDetailScreenActions.onEdit(
                                      context,
                                      details!,
                                    );
                                    if (updated == true && mounted) {
                                      _hasUpdated = true;
                                    }
                                  }
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
                              child:Image.asset(Assets.images.appLogoClearBg.path).paddingAll(5)
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
                            // Receipt No
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Receipt No',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    inv.hashId.isNotEmpty ? inv.hashId : 'MD-${inv.id}',
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Date row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    createdDateStr,
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Table row below Date
                            () {
                              final tableName = (details?.tableName != null && details!.tableName!.isNotEmpty)
                                  ? details.tableName!
                                  : (inv.orderId != null ? 'Table ${inv.orderId}' : 'Dine-In');
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Table / Dine-In',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      tableName,
                                      textAlign: TextAlign.end,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }(),
                            const SizedBox(height: 6),
                            // Payment Mode row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Mode',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    inv.paymentMethodName ?? 'Cash',
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                                          core.CurrencyFormatter.format(value: item.unitPrice),
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
                                          core.CurrencyFormatter.format(value: item.totalPrice),
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
                                Text(core.CurrencyFormatter.format(value: inv.totalCost)),
                              ],
                            ),
                            if (inv.paymentMethodDetails != null &&
                                inv.paymentMethodDetails!.isNotEmpty) ...[
                              () {
                                try {
                                  final detailsMap = jsonDecode(inv.paymentMethodDetails!) as Map<String, dynamic>;
                                  final taxList = (detailsMap['taxDetails'] as List<dynamic>?) ?? [];
                                  final chargeList = (detailsMap['chargeDetails'] as List<dynamic>?) ?? [];
                                  final discountList = (detailsMap['discountDetails'] as List<dynamic>?) ?? [];

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ...discountList.where((d) => ((d['amount'] as num?)?.toDouble() ?? 0.0) > 0).map((d) {
                                        final name = d['name'] ?? 'Discount';
                                        final amt = (d['amount'] as num?)?.toDouble() ?? 0.0;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(name.toString(), style: const TextStyle(color: Colors.grey)),
                                              Text(
                                                '-${core.CurrencyFormatter.format(value: amt)}',
                                                style: const TextStyle(color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      ...taxList.where((t) => ((t['amount'] as num?)?.toDouble() ?? 0.0) > 0).map((t) {
                                        final name = t['name'] ?? 'Tax';
                                        final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(name.toString(), style: const TextStyle(color: Colors.grey)),
                                              Text('+${core.CurrencyFormatter.format(value: amt)}'),
                                            ],
                                          ),
                                        );
                                      }),
                                      ...chargeList.where((c) => ((c['amount'] as num?)?.toDouble() ?? 0.0) > 0).map((c) {
                                        final name = c['name'] ?? 'Extra Charge';
                                        final amt = (c['amount'] as num?)?.toDouble() ?? 0.0;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(name.toString(), style: const TextStyle(color: Colors.grey)),
                                              Text('+${core.CurrencyFormatter.format(value: amt)}'),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                } catch (_) {
                                  return const SizedBox.shrink();
                                }
                              }(),
                            ] else if (inv.taxCost > 0 || inv.discountAmount > 0) ...[
                              if (inv.discountAmount > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Discount', style: TextStyle(color: Colors.grey)),
                                      Text(
                                        '-${core.CurrencyFormatter.format(value: inv.discountAmount)}',
                                        style: const TextStyle(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                              if (inv.taxCost > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Tax', style: TextStyle(color: Colors.grey)),
                                      Text('+${core.CurrencyFormatter.format(value: inv.taxCost)}'),
                                    ],
                                  ),
                                ),
                            ],
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
                                  core.CurrencyFormatter.format(value: inv.netPaymentAmount),
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
                                const Text('Payment Method'),
                                Text(
                                  inv.paymentMethodName ?? 'Cash',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            if (inv.cashReceived != null && inv.cashReceived! > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Cash Received'),
                                  Text(
                                    core.CurrencyFormatter.format(value: inv.cashReceived!),
                                  ),
                                ],
                              ),
                            ],
                            if (inv.changeAmount != null && inv.changeAmount! > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Change Amount'),
                                  Text(
                                    core.CurrencyFormatter.format(value: inv.changeAmount!),
                                  ),
                                ],
                              ),
                            ],
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
                            // const SizedBox(height: 4),
                            // Text(
                            //   context.tr(
                            //         shared.LocaleKeys.invoiceFooterPoweredBy,
                            //         track:
                            //             shared.TrackConstants.invoicePageTrack,
                            //       ) ??
                            //       'Powered By Coozy The cafe POS',
                            //   style: theme.textTheme.bodyMedium?.copyWith(
                            //     fontStyle: FontStyle.italic,
                            //     color: colorScheme.onSurfaceVariant,
                            //   ),
                            // ),
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

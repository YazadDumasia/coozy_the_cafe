import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/invoice_management_bloc.dart';
import '../../../domain/entities/invoice_management_entity.dart';
import 'widget/invoice_list_filter_bottom_sheet.dart';

class InvoiceListScreenActions {
  static void onSearchQueryChanged(BuildContext context, String query) {
    context.read<InvoiceManagementBloc>().add(
          LoadInvoicesEvent(
            isRefresh: true,
            searchQuery: query,
          ),
        );
  }

  static Future<void> onInvoiceTapped(
    BuildContext context,
    InvoiceEntity invoice,
  ) async {
    await context.push(
      AppRoutePath.invoiceDetailRoute(
        invoice.hashId.isNotEmpty ? invoice.hashId : invoice.id,
      ),
      extra: invoice,
    );
    if (context.mounted) {
      context.read<InvoiceManagementBloc>().add(
            const LoadInvoicesEvent(isRefresh: true),
          );
    }
  }

  static void openFilterBottomSheet({
    required BuildContext context,
    required ValueNotifier<List<shared.AppliedFilterModel>> appliedFiltersNotifier,
    required List<PaymentMode> paymentModes,
  }) {
    showInvoiceFilterBottomSheet(
      context: context,
      appliedFiltersNotifier: appliedFiltersNotifier,
      paymentModes: paymentModes,
      onApply: (applied) {
        final List<String> methods = [];
        for (final filter in applied) {
          if (filter.filterKey == 'payment_mode') {
            for (final item in filter.applied) {
              methods.add(item.filterKey);
            }
          }
        }
        context.read<InvoiceManagementBloc>().add(
              LoadInvoicesEvent(
                isRefresh: true,
                paymentMethods: methods,
              ),
            );
      },
    );
  }

  static void removeAppliedFilterKey({
    required BuildContext context,
    required ValueNotifier<List<shared.AppliedFilterModel>> appliedFiltersNotifier,
    required String filterKey,
  }) {
    final current = List<shared.AppliedFilterModel>.from(appliedFiltersNotifier.value);
    for (int i = 0; i < current.length; i++) {
      final f = current[i];
      final newApplied = f.applied.where((item) => item.filterKey != filterKey).toList();
      current[i] = shared.AppliedFilterModel(
        filterKey: f.filterKey,
        applied: newApplied,
        filterTitle: f.filterTitle,
      );
    }
    current.removeWhere((f) => f.applied.isEmpty);
    appliedFiltersNotifier.value = current;

    final List<String> methods = [];
    for (final filter in current) {
      if (filter.filterKey == 'payment_mode') {
        for (final item in filter.applied) {
          methods.add(item.filterKey);
        }
      }
    }
    context.read<InvoiceManagementBloc>().add(
          LoadInvoicesEvent(
            isRefresh: true,
            paymentMethods: methods,
          ),
        );
  }

  static void clearAllFilters({
    required BuildContext context,
    required ValueNotifier<List<shared.AppliedFilterModel>> appliedFiltersNotifier,
  }) {
    appliedFiltersNotifier.value = [];
    context.read<InvoiceManagementBloc>().add(
          const LoadInvoicesEvent(
            isRefresh: true,
            paymentMethods: [],
          ),
        );
  }
}

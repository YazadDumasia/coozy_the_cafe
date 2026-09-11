import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../../bloc/invoice_management_bloc.dart';
import '../../../domain/entities/invoice_management_entity.dart';

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
}

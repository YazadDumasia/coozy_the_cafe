import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/invoice_management_bloc.dart';
import '../../../domain/entities/invoice_management_entity.dart';

class EditInvoiceScreenActions {
  static void onSave(
    BuildContext context, {
    required InvoiceEntity invoice,
    required List<InvoiceItemEntity> items,
  }) {
    context.read<InvoiceManagementBloc>().add(
          UpdateInvoiceEvent(
            invoice: invoice,
            items: items,
          ),
        );
    context.pop();
  }
}

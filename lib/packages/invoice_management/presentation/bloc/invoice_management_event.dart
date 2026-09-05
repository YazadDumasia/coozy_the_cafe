part of 'invoice_management_bloc.dart';

sealed class InvoiceManagementEvent extends Equatable {
  const InvoiceManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvoicesEvent extends InvoiceManagementEvent {
  final bool isRefresh;
  final String? searchQuery;
  final DateTimeRange? dateRange;

  const LoadInvoicesEvent({
    this.isRefresh = false,
    this.searchQuery,
    this.dateRange,
  });

  @override
  List<Object?> get props => [isRefresh, searchQuery, dateRange];
}

class LoadMoreInvoicesEvent extends InvoiceManagementEvent {
  const LoadMoreInvoicesEvent();
}

class SelectInvoiceDateRangeEvent extends InvoiceManagementEvent {
  final DateTimeRange? dateRange;

  const SelectInvoiceDateRangeEvent(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

class LoadInvoiceDetailsEvent extends InvoiceManagementEvent {
  final int invoiceId;

  const LoadInvoiceDetailsEvent(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class UpdateInvoiceEvent extends InvoiceManagementEvent {
  final InvoiceEntity invoice;
  final List<InvoiceItemEntity> items;

  const UpdateInvoiceEvent({
    required this.invoice,
    required this.items,
  });

  @override
  List<Object?> get props => [invoice, items];
}

class DeleteInvoiceEvent extends InvoiceManagementEvent {
  final int invoiceId;

  const DeleteInvoiceEvent(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

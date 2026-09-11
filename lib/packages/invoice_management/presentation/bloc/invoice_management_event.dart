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

class LoadInvoiceDetailsByOrderIdEvent extends InvoiceManagementEvent {
  final int orderId;

  const LoadInvoiceDetailsByOrderIdEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class LoadInvoiceDetailsByOrderHashIdEvent extends InvoiceManagementEvent {
  final String orderHashId;

  const LoadInvoiceDetailsByOrderHashIdEvent(this.orderHashId);

  @override
  List<Object?> get props => [orderHashId];
}

class LoadInvoiceDetailsByHashIdEvent extends InvoiceManagementEvent {
  final String hashId;

  const LoadInvoiceDetailsByHashIdEvent(this.hashId);

  @override
  List<Object?> get props => [hashId];
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

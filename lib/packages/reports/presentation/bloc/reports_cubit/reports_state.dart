part of 'reports_cubit.dart';

sealed class ReportsState {}

final class ReportsInitial extends ReportsState {}

final class ReportsLoading extends ReportsState {}

final class ReportsDailySalesLoaded extends ReportsState {
  ReportsDailySalesLoaded(this.entries);
  final List<DailySalesEntry> entries;
}

final class ReportsMonthlySalesLoaded extends ReportsState {
  ReportsMonthlySalesLoaded(this.entries);
  final List<MonthlySalesEntry> entries;
}

final class ReportsTopItemsLoaded extends ReportsState {
  ReportsTopItemsLoaded(this.items);
  final List<TopItemEntry> items;
}

final class ReportsPaymentModesLoaded extends ReportsState {
  ReportsPaymentModesLoaded(this.entries);
  final List<PaymentModeEntry> entries;
}

final class ReportsDashboardLoaded extends ReportsState {
  ReportsDashboardLoaded(this.dashboard);
  final SalesDashboard dashboard;
}

final class ReportsInventoryStockLoaded extends ReportsState {
  ReportsInventoryStockLoaded(this.entries);
  final List<InventoryStockEntry> entries;
}

final class ReportsPurchasesLoaded extends ReportsState {
  ReportsPurchasesLoaded(this.entries);
  final List<PurchaseSummaryEntry> entries;
}

final class ReportsExpenditureLoaded extends ReportsState {
  ReportsExpenditureLoaded(this.entries);
  final List<ExpenditureSummaryEntry> entries;
}

final class ReportsMenuItemSalesLoaded extends ReportsState {
  ReportsMenuItemSalesLoaded(this.entries);
  final List<MenuItemSalesEntry> entries;
}

final class ReportsError extends ReportsState {
  ReportsError(this.message);
  final String message;
}

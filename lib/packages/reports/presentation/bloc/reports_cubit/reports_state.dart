part of 'reports_cubit.dart';

sealed class ReportsState {}

final class ReportsInitial extends ReportsState {}

final class ReportsLoading extends ReportsState {}

final class ReportsSalesTrendsLoaded extends ReportsState {
  ReportsSalesTrendsLoaded(this.entries, this.format);
  final List<SalesTrendEntry> entries;
  final SalesPeriodFormat format;
}

final class ReportsDailySalesLoaded extends ReportsState {
  ReportsDailySalesLoaded(this.entries);
  final List<DailySalesEntry> entries;
}

final class ReportsMonthlySalesLoaded extends ReportsState {
  ReportsMonthlySalesLoaded(this.entries);
  final List<MonthlySalesEntry> entries;
}

final class ReportsTopItemsLoaded extends ReportsState {
  ReportsTopItemsLoaded(this.items, [this.format = SalesPeriodFormat.daily]);
  final List<TopItemEntry> items;
  final SalesPeriodFormat format;
}

final class ReportsPaymentModesLoaded extends ReportsState {
  ReportsPaymentModesLoaded(
    this.entries, [
    this.format = SalesPeriodFormat.daily,
  ]);
  final List<PaymentModeEntry> entries;
  final SalesPeriodFormat format;
}

final class ReportsDashboardLoaded extends ReportsState {
  ReportsDashboardLoaded(
    this.dashboard, [
    this.format = SalesPeriodFormat.daily,
  ]);
  final SalesDashboard dashboard;
  final SalesPeriodFormat format;
}

final class ReportsInventoryStockLoaded extends ReportsState {
  ReportsInventoryStockLoaded(this.entries);
  final List<InventoryStockEntry> entries;
}

final class ReportsPurchasesLoaded extends ReportsState {
  ReportsPurchasesLoaded(this.entries, [this.format = SalesPeriodFormat.daily]);
  final List<PurchaseSummaryEntry> entries;
  final SalesPeriodFormat format;
}

final class ReportsExpenditureLoaded extends ReportsState {
  ReportsExpenditureLoaded(
    this.entries, [
    this.format = SalesPeriodFormat.daily,
  ]);
  final List<ExpenditureSummaryEntry> entries;
  final SalesPeriodFormat format;
}

final class ReportsMenuItemSalesLoaded extends ReportsState {
  ReportsMenuItemSalesLoaded(
    this.entries, [
    this.format = SalesPeriodFormat.daily,
  ]);
  final List<MenuItemSalesEntry> entries;
  final SalesPeriodFormat format;
}

final class ReportsStockAdjustmentsLoaded extends ReportsState {
  ReportsStockAdjustmentsLoaded(
    this.entries, [
    this.format = SalesPeriodFormat.daily,
  ]);
  final List<StockAdjustmentEntry> entries;
  final SalesPeriodFormat format;
}

final class ReportsError extends ReportsState {
  ReportsError(this.message);
  final String message;
}

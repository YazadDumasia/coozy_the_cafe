import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/daily_sales_entry.dart';
import '../../../domain/entities/monthly_sales_entry.dart';
import '../../../domain/entities/sales_trend_entry.dart';
import '../../../domain/entities/top_item_entry.dart';
import '../../../domain/entities/payment_mode_entry.dart';
import '../../../domain/entities/sales_dashboard.dart';
import '../../../domain/entities/inventory_stock_entry.dart';
import '../../../domain/entities/purchase_summary_entry.dart';
import '../../../domain/entities/expenditure_summary_entry.dart';
import '../../../domain/entities/menu_item_sales_entry.dart';
import '../../../domain/entities/stock_adjustment_entry.dart';
import '../../../domain/entities/report_category.dart';
import '../../../domain/usecases/reports_usecases.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';

part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({
    required this.getSalesTrendsReportUseCase,
    required this.getDailySalesSummaryUseCase,
    required this.getMonthlySalesSummaryUseCase,
    required this.getTopSellingItemsUseCase,
    required this.getPaymentModeReportUseCase,
    required this.getSalesDashboardUseCase,
    required this.getInventoryStockReportUseCase,
    required this.getPurchaseSummaryReportUseCase,
    required this.getExpenditureSummaryReportUseCase,
    required this.getMenuItemSalesReportUseCase,
    required this.getStockAdjustmentsReportUseCase,
  }) : super(ReportsInitial());

  final GetSalesTrendsReportUseCase getSalesTrendsReportUseCase;
  final GetDailySalesSummaryUseCase getDailySalesSummaryUseCase;
  final GetMonthlySalesSummaryUseCase getMonthlySalesSummaryUseCase;
  final GetTopSellingItemsUseCase getTopSellingItemsUseCase;
  final GetPaymentModeReportUseCase getPaymentModeReportUseCase;
  final GetSalesDashboardUseCase getSalesDashboardUseCase;
  final GetInventoryStockReportUseCase getInventoryStockReportUseCase;
  final GetPurchaseSummaryReportUseCase getPurchaseSummaryReportUseCase;
  final GetExpenditureSummaryReportUseCase getExpenditureSummaryReportUseCase;
  final GetMenuItemSalesReportUseCase getMenuItemSalesReportUseCase;
  final GetStockAdjustmentsReportUseCase getStockAdjustmentsReportUseCase;

  DateTimeRange _currentRange = DateTimeRange(
    start: DateUtil.startOfDay(
      DateTime.now().subtract(const Duration(days: 29)),
    ),
    end: DateUtil.endOfDay(DateTime.now()),
  );
  String? _currentItemNameFilter;
  SalesPeriodFormat _currentPeriodFormat = SalesPeriodFormat.daily;
  ReportType _currentReportType = ReportType.salesTrends;

  SalesPeriodFormat get currentPeriodFormat => _currentPeriodFormat;
  ReportType get currentReportType => _currentReportType;

  void loadReport(
    ReportType type,
    DateTimeRange dateRange, {
    String? itemName,
    SalesPeriodFormat? periodFormat,
  }) {
    _currentReportType = type;
    _currentRange = dateRange;
    _currentItemNameFilter = itemName;
    if (periodFormat != null) {
      _currentPeriodFormat = periodFormat;
    }
    switch (type) {
      case ReportType.salesTrends:
        _loadSalesTrends();
      case ReportType.dailySales:
        _currentPeriodFormat = SalesPeriodFormat.daily;
        _loadSalesTrends();
      case ReportType.monthlySales:
        _currentPeriodFormat = SalesPeriodFormat.monthly;
        _loadSalesTrends();
      case ReportType.topSellingItems:
        _loadTopItems();
      case ReportType.paymentModes:
        _loadPaymentModes();
      case ReportType.salesDashboard:
        _loadDashboard();
      case ReportType.inventoryStock:
        _loadInventoryStock();
      case ReportType.purchases:
        _loadPurchases();
      case ReportType.expenditure:
        _loadExpenditure();
      case ReportType.menuItemSales:
        _loadMenuItemSales();
      case ReportType.stockAdjustments:
        _loadStockAdjustments();
    }
  }

  void changeSalesPeriodFormat(SalesPeriodFormat format) {
    _currentPeriodFormat = format;
    refresh(_currentReportType);
  }

  void refresh(ReportType type) =>
      loadReport(type, _currentRange, itemName: _currentItemNameFilter);

  String _startIso() =>
      DateUtil.startOfDay(_currentRange.start).toIso8601String();
  String _endIso() => DateUtil.endOfDay(_currentRange.end).toIso8601String();

  Future<void> _loadSalesTrends() async {
    emit(ReportsLoading());
    try {
      final entries = await getSalesTrendsReportUseCase(
        _startIso(),
        _endIso(),
        format: _currentPeriodFormat,
      );
      emit(ReportsSalesTrendsLoaded(entries, _currentPeriodFormat));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _loadTopItems() async {
    emit(ReportsLoading());
    try {
      final items = await getTopSellingItemsUseCase(
        _startIso(),
        _endIso(),
        limit: 15,
      );
      emit(ReportsTopItemsLoaded(items, _currentPeriodFormat));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _loadPaymentModes() async {
    emit(ReportsLoading());
    try {
      final entries = await getPaymentModeReportUseCase(_startIso(), _endIso());
      emit(ReportsPaymentModesLoaded(entries, _currentPeriodFormat));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _loadDashboard() async {
    emit(ReportsLoading());
    try {
      final dashboard = await getSalesDashboardUseCase(_startIso(), _endIso());
      emit(ReportsDashboardLoaded(dashboard, _currentPeriodFormat));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _loadInventoryStock() async {
    emit(ReportsLoading());
    try {
      final entries = await getInventoryStockReportUseCase();
      emit(ReportsInventoryStockLoaded(entries));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _loadPurchases() async {
    emit(ReportsLoading());
    try {
      final entries = await getPurchaseSummaryReportUseCase(
        _startIso(),
        _endIso(),
        format: _currentPeriodFormat,
      );
      emit(ReportsPurchasesLoaded(entries, _currentPeriodFormat));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _loadExpenditure() async {
    emit(ReportsLoading());
    try {
      final entries = await getExpenditureSummaryReportUseCase(
        _startIso(),
        _endIso(),
        format: _currentPeriodFormat,
      );
      emit(ReportsExpenditureLoaded(entries, _currentPeriodFormat));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _loadMenuItemSales() async {
    emit(ReportsLoading());
    try {
      final entries = await getMenuItemSalesReportUseCase(
        _startIso(),
        _endIso(),
        itemName: _currentItemNameFilter,
        format: _currentPeriodFormat,
      );
      emit(ReportsMenuItemSalesLoaded(entries, _currentPeriodFormat));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _loadStockAdjustments() async {
    emit(ReportsLoading());
    try {
      final entries = await getStockAdjustmentsReportUseCase(
        _startIso(),
        _endIso(),
        format: _currentPeriodFormat,
      );
      emit(ReportsStockAdjustmentsLoaded(entries, _currentPeriodFormat));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }
}

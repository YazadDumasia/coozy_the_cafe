import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/daily_sales_entry.dart';
import '../../../domain/entities/monthly_sales_entry.dart';
import '../../../domain/entities/top_item_entry.dart';
import '../../../domain/entities/payment_mode_entry.dart';
import '../../../domain/entities/sales_dashboard.dart';
import '../../../domain/entities/inventory_stock_entry.dart';
import '../../../domain/entities/purchase_summary_entry.dart';
import '../../../domain/entities/expenditure_summary_entry.dart';
import '../../../domain/entities/menu_item_sales_entry.dart';
import '../../../domain/entities/report_category.dart';
import '../../../domain/usecases/reports_usecases.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';

part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({
    required this.getDailySalesSummaryUseCase,
    required this.getMonthlySalesSummaryUseCase,
    required this.getTopSellingItemsUseCase,
    required this.getPaymentModeReportUseCase,
    required this.getSalesDashboardUseCase,
    required this.getInventoryStockReportUseCase,
    required this.getPurchaseSummaryReportUseCase,
    required this.getExpenditureSummaryReportUseCase,
    required this.getMenuItemSalesReportUseCase,
  }) : super(ReportsInitial());

  final GetDailySalesSummaryUseCase getDailySalesSummaryUseCase;
  final GetMonthlySalesSummaryUseCase getMonthlySalesSummaryUseCase;
  final GetTopSellingItemsUseCase getTopSellingItemsUseCase;
  final GetPaymentModeReportUseCase getPaymentModeReportUseCase;
  final GetSalesDashboardUseCase getSalesDashboardUseCase;
  final GetInventoryStockReportUseCase getInventoryStockReportUseCase;
  final GetPurchaseSummaryReportUseCase getPurchaseSummaryReportUseCase;
  final GetExpenditureSummaryReportUseCase getExpenditureSummaryReportUseCase;
  final GetMenuItemSalesReportUseCase getMenuItemSalesReportUseCase;

  late DateTimeRange _currentRange;
  String? _currentItemNameFilter;

  void loadReport(
    ReportType type,
    DateTimeRange dateRange, {
    String? itemName,
  }) {
    _currentRange = dateRange;
    _currentItemNameFilter = itemName;
    switch (type) {
      case ReportType.dailySales:
        _loadDailySales();
      case ReportType.monthlySales:
        _loadMonthlySales();
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
    }
  }

  void refresh(ReportType type) =>
      loadReport(type, _currentRange, itemName: _currentItemNameFilter);

  String _startIso() =>
      DateUtil.startOfDay(_currentRange.start).toIso8601String();
  String _endIso() => DateUtil.endOfDay(_currentRange.end).toIso8601String();

  Future<void> _loadDailySales() async {
    emit(ReportsLoading());
    try {
      final entries = await getDailySalesSummaryUseCase(_startIso(), _endIso());
      emit(ReportsDailySalesLoaded(entries));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _loadMonthlySales() async {
    emit(ReportsLoading());
    try {
      final entries = await getMonthlySalesSummaryUseCase(
        _startIso(),
        _endIso(),
      );
      emit(ReportsMonthlySalesLoaded(entries));
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
      emit(ReportsTopItemsLoaded(items));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _loadPaymentModes() async {
    emit(ReportsLoading());
    try {
      final entries = await getPaymentModeReportUseCase(_startIso(), _endIso());
      emit(ReportsPaymentModesLoaded(entries));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _loadDashboard() async {
    emit(ReportsLoading());
    try {
      final dashboard = await getSalesDashboardUseCase(_startIso(), _endIso());
      emit(ReportsDashboardLoaded(dashboard));
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
      );
      emit(ReportsPurchasesLoaded(entries));
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
      );
      emit(ReportsExpenditureLoaded(entries));
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
      );
      emit(ReportsMenuItemSalesLoaded(entries));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }
}

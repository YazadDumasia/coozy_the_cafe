import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/reports_cubit/reports_cubit.dart';
import '../../../domain/entities/report_category.dart';
import '../../services/report_export_service.dart';
import 'widget/date_range_filter_bar.dart';
import 'widget/sales_line_chart.dart';
import 'widget/monthly_bar_chart.dart';
import 'widget/top_items_bar_chart.dart';
import 'widget/payment_mode_pie_chart.dart';
import 'widget/dashboard_kpi_card.dart';
import 'widget/inventory_stock_bar_chart.dart';
import 'widget/purchase_summary_bar_chart.dart';
import 'widget/expenditure_summary_pie_chart.dart';
import 'widget/menu_item_sales_bar_chart.dart';
import 'widget/report_data_table.dart';

class ReportDetailPage extends StatefulWidget {
  const ReportDetailPage({super.key, required this.category});
  final ReportCategory category;

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  DateTimeRange? _range;
  late final ValueNotifier<bool> _isTableViewNotifier;

  @override
  void initState() {
    super.initState();
    _isTableViewNotifier = ValueNotifier<bool>(false);
    if (widget.category.type == ReportType.inventoryStock) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final now = DateTime.now();
        context.read<ReportsCubit>().loadReport(
          widget.category.type,
          DateTimeRange(start: now, end: now),
          itemName: widget.category.filterItemName,
        );
      });
    }
  }

  @override
  void dispose() {
    _isTableViewNotifier.dispose();
    super.dispose();
  }

  void _onRangeChanged(DateTimeRange range) {
    _range = range;
    context.read<ReportsCubit>().loadReport(
      widget.category.type,
      range,
      itemName: widget.category.filterItemName,
    );
  }

  String? _formatDateRangeStr() {
    if (_range == null) return null;
    final s = _range!.start.toIso8601String().substring(0, 10);
    final e = _range!.end.toIso8601String().substring(0, 10);
    return '$s to $e';
  }

  ReportExportRowData? _extractExportData(
    ReportsState state,
    BuildContext context,
  ) {
    final rangeStr = _formatDateRangeStr();
    final title = widget.category.title;

    if (state is ReportsDailySalesLoaded) {
      final headers = [
        context.tr(
              shared.LocaleKeys.reportPageColumnDate,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Date',
        context.tr(
              shared.LocaleKeys.reportPageColumnInvoices,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Invoices',
        context.tr(
              shared.LocaleKeys.reportPageColumnTotalSales,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Gross Sales',
        context.tr(
              shared.LocaleKeys.reportPageColumnTax,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Tax',
        context.tr(
              shared.LocaleKeys.reportPageTotalDiscount,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Discount',
        context.tr(
              shared.LocaleKeys.reportPageColumnNetSales,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Net Sales',
        context.tr(
              shared.LocaleKeys.reportPageColumnCost,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Cost',
        context.tr(
              shared.LocaleKeys.reportPageColumnProfit,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Profit',
        context.tr(
              shared.LocaleKeys.reportPageColumnMargin,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Margin %',
      ];
      final rows = state.entries.map((e) {
        return [
          e.saleDate,
          e.totalInvoices,
          e.totalSales,
          e.totalTax,
          e.totalDiscount,
          e.netTotal,
          e.dailyCost,
          e.dailyProfit,
          e.profitPercentage != null
              ? '${e.profitPercentage!.toStringAsFixed(1)}%'
              : '—',
        ];
      }).toList();
      return ReportExportRowData(
        reportTitle: title,
        dateRangeStr: rangeStr,
        headers: headers,
        rows: rows,
      );
    }

    if (state is ReportsMonthlySalesLoaded) {
      final headers = [
        context.tr(
              shared.LocaleKeys.reportPageColumnMonth,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Month',
        context.tr(
              shared.LocaleKeys.reportPageColumnInvoices,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Invoices',
        context.tr(
              shared.LocaleKeys.reportPageColumnTotalSales,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Gross Sales',
        context.tr(
              shared.LocaleKeys.reportPageColumnTax,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Tax',
        context.tr(
              shared.LocaleKeys.reportPageTotalDiscount,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Discount',
        context.tr(
              shared.LocaleKeys.reportPageColumnNetSales,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Net Sales',
        context.tr(
              shared.LocaleKeys.reportPageColumnCost,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Cost',
        context.tr(
              shared.LocaleKeys.reportPageColumnProfit,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Profit',
        context.tr(
              shared.LocaleKeys.reportPageColumnMargin,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Margin %',
      ];
      final rows = state.entries.map((e) {
        return [
          e.saleMonth,
          e.totalInvoices,
          e.totalSales,
          e.totalTax,
          e.totalDiscount,
          e.netTotal,
          e.monthlyCost,
          e.monthlyProfit,
          e.profitPercentage != null
              ? '${e.profitPercentage!.toStringAsFixed(1)}%'
              : '—',
        ];
      }).toList();
      return ReportExportRowData(
        reportTitle: title,
        dateRangeStr: rangeStr,
        headers: headers,
        rows: rows,
      );
    }

    if (state is ReportsTopItemsLoaded) {
      final headers = [
        context.tr(
              shared.LocaleKeys.reportPageColumnItemName,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Item Name',
        context.tr(
              shared.LocaleKeys.reportPageColumnQuantity,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Qty Sold',
        context.tr(
              shared.LocaleKeys.reportPageColumnAmount,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Revenue',
        context.tr(
              shared.LocaleKeys.reportPageColumnCost,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Cost',
        context.tr(
              shared.LocaleKeys.reportPageColumnProfit,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Profit',
      ];
      final rows = state.items.map((e) {
        return [
          e.itemName,
          e.totalQuantity,
          e.totalRevenue,
          e.totalCost,
          e.profit,
        ];
      }).toList();
      return ReportExportRowData(
        reportTitle: title,
        dateRangeStr: rangeStr,
        headers: headers,
        rows: rows,
      );
    }

    if (state is ReportsMenuItemSalesLoaded) {
      final headers = [
        context.tr(
              shared.LocaleKeys.reportPageColumnItemName,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Item Name',
        context.tr(
              shared.LocaleKeys.reportPageColumnDate,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Date',
        context.tr(
              shared.LocaleKeys.reportPageColumnQuantity,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Qty Sold',
        context.tr(
              shared.LocaleKeys.reportPageColumnAmount,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Total Amount',
        context.tr(
              shared.LocaleKeys.reportPageColumnCost,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Total Cost',
        context.tr(
              shared.LocaleKeys.reportPageColumnProfit,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Profit',
        context.tr(
              shared.LocaleKeys.reportPageColumnMargin,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Margin %',
      ];
      final rows = state.entries.map((e) {
        return [
          e.itemName,
          e.saleDate,
          e.quantitySold,
          e.totalAmount,
          e.totalCost,
          e.totalProfit,
          e.profitPercentage != null
              ? '${e.profitPercentage!.toStringAsFixed(1)}%'
              : '—',
        ];
      }).toList();
      return ReportExportRowData(
        reportTitle: title,
        dateRangeStr: rangeStr,
        headers: headers,
        rows: rows,
      );
    }

    if (state is ReportsPaymentModesLoaded) {
      final headers = [
        context.tr(
              shared.LocaleKeys.reportPageColumnPaymentMethod,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Payment Method',
        context.tr(
              shared.LocaleKeys.reportPageColumnTransactions,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Transactions',
        context.tr(
              shared.LocaleKeys.reportPageColumnAmount,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Total Amount',
      ];
      final rows = state.entries.map((e) {
        return [e.paymentMethodName, e.transactionCount, e.totalAmount];
      }).toList();
      return ReportExportRowData(
        reportTitle: title,
        dateRangeStr: rangeStr,
        headers: headers,
        rows: rows,
      );
    }

    if (state is ReportsDashboardLoaded) {
      final d = state.dashboard;
      final headers = [
        context.tr(
              shared.LocaleKeys.commonDescription,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Metric',
        context.tr(
              shared.LocaleKeys.reportPageColumnAmount,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Value',
      ];
      final rows = [
        ['Total Invoices', d.totalInvoices],
        ['Gross Sales', d.totalSales],
        ['Total Tax', d.totalTax],
        ['Total Discount', d.totalDiscount],
        ['Net Total', d.netTotal],
        ['Average Order Value', d.averageOrderValue],
        ['Total Cost', d.totalCost],
        ['Total Profit', d.totalProfit],
        [
          'Profit Margin %',
          d.profitPercentage != null
              ? '${d.profitPercentage!.toStringAsFixed(1)}%'
              : '—',
        ],
      ];
      return ReportExportRowData(
        reportTitle: title,
        dateRangeStr: rangeStr,
        headers: headers,
        rows: rows,
      );
    }

    if (state is ReportsInventoryStockLoaded) {
      final headers = [
        context.tr(
              shared.LocaleKeys.reportPageColumnItemName,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Item Name',
        context.tr(
              shared.LocaleKeys.reportPageColumnStock,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Current Stock',
        context.tr(
              shared.LocaleKeys.reportPageColumnUnit,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Unit',
      ];
      final rows = state.entries.map((e) {
        return [e.name, e.currentStock, e.purchaseUnit];
      }).toList();
      return ReportExportRowData(
        reportTitle: title,
        dateRangeStr: 'Current Status',
        headers: headers,
        rows: rows,
      );
    }

    if (state is ReportsPurchasesLoaded) {
      final headers = [
        context.tr(
              shared.LocaleKeys.reportPageColumnItemName,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Item Name',
        context.tr(
              shared.LocaleKeys.reportPageColumnUnit,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Unit',
        context.tr(
              shared.LocaleKeys.reportPageColumnQuantity,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Qty Bought',
        context.tr(
              shared.LocaleKeys.reportPageColumnCost,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Total Cost',
      ];
      final rows = state.entries.map((e) {
        return [e.itemName, e.purchaseUnit, e.totalQty, e.totalCost];
      }).toList();
      return ReportExportRowData(
        reportTitle: title,
        dateRangeStr: rangeStr,
        headers: headers,
        rows: rows,
      );
    }

    if (state is ReportsExpenditureLoaded) {
      final headers = [
        context.tr(
              shared.LocaleKeys.reportPageColumnType,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Type',
        context.tr(
              shared.LocaleKeys.reportPageColumnCategory,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Category',
        context.tr(
              shared.LocaleKeys.reportPageColumnTransactions,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Transactions',
        context.tr(
              shared.LocaleKeys.reportPageColumnAmount,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Total Amount',
      ];
      final rows = state.entries.map((e) {
        return [e.type, e.categoryName, e.transactionCount, e.totalAmount];
      }).toList();
      return ReportExportRowData(
        reportTitle: title,
        dateRangeStr: rangeStr,
        headers: headers,
        rows: rows,
      );
    }

    return null;
  }

  void _showExportModal(BuildContext context, ReportsState state) {
    final exportData = _extractExportData(state, context);
    if (exportData == null || exportData.rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
                  shared.LocaleKeys.reportPageEmptyData,
                  track: shared.TrackConstants.reportPageTrack,
                ) ??
                'No data found for the selected range',
          ),
        ),
      );
      return;
    }

    final scheme = Theme.of(context).colorScheme;
    final safeName =
        '${widget.category.id}_report_${DateTime.now().millisecondsSinceEpoch}';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.reportPageExportButton,
                          track: shared.TrackConstants.reportPageTrack,
                        ) ??
                        'Export Report',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.red,
                    ),
                  ),
                  title: Text(
                    context.tr(
                          shared.LocaleKeys.reportPageExportAsPdf,
                          track: shared.TrackConstants.reportPageTrack,
                        ) ??
                        'Export as PDF',
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final result = await ReportExportService.exportToPdf(
                      exportData,
                      baseFilename: safeName,
                    );
                    _handleExportResult(result);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.table_chart_rounded,
                      color: Colors.green,
                    ),
                  ),
                  title: Text(
                    context.tr(
                          shared.LocaleKeys.reportPageExportAsExcel,
                          track: shared.TrackConstants.reportPageTrack,
                        ) ??
                        'Export as Excel (.xlsx)',
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final result = await ReportExportService.exportToExcel(
                      exportData,
                      baseFilename: safeName,
                    );
                    _handleExportResult(result);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.file_present_rounded,
                      color: scheme.primary,
                    ),
                  ),
                  title: Text(
                    context.tr(
                          shared.LocaleKeys.reportPageExportAsCsv,
                          track: shared.TrackConstants.reportPageTrack,
                        ) ??
                        'Export as CSV',
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final result = await ReportExportService.exportToCsv(
                      exportData,
                      baseFilename: safeName,
                    );
                    _handleExportResult(result);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleExportResult(shared.PdfSaveResult result) {
    if (!mounted) return;
    if (result.isSuccess) {
      final successMsg =
          context.tr(
            shared.LocaleKeys.reportPageExportSuccess,
            track: shared.TrackConstants.reportPageTrack,
            params: {'filename': result.filePath ?? 'Report'},
          ) ??
          'Report exported successfully';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMsg), backgroundColor: Colors.green),
      );
    } else {
      final errorMsg =
          context.tr(
            shared.LocaleKeys.reportPageExportFailed,
            track: shared.TrackConstants.reportPageTrack,
            params: {'error': result.errorMessage ?? 'Unknown error'},
          ) ??
          'Export failed: ${result.errorMessage}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDateFilterable = widget.category.type != ReportType.inventoryStock;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        actions: [
          // Table / Chart view toggle
          ValueListenableBuilder<bool>(
            valueListenable: _isTableViewNotifier,
            builder: (context, isTableView, _) {
              return IconButton(
                tooltip: isTableView
                    ? (context.tr(
                            shared.LocaleKeys.reportPageToggleChart,
                            track: shared.TrackConstants.reportPageTrack,
                          ) ??
                          'View Chart')
                    : (context.tr(
                            shared.LocaleKeys.reportPageToggleTable,
                            track: shared.TrackConstants.reportPageTrack,
                          ) ??
                          'View Table'),
                icon: Icon(
                  isTableView
                      ? Icons.bar_chart_rounded
                      : Icons.table_rows_rounded,
                ),
                onPressed: () {
                  _isTableViewNotifier.value = !isTableView;
                },
              );
            },
          ),
          // Export button
          BlocBuilder<ReportsCubit, ReportsState>(
            builder: (context, state) {
              final isExportable =
                  state is! ReportsLoading &&
                  state is! ReportsError &&
                  state is! ReportsInitial;
              return IconButton(
                tooltip:
                    context.tr(
                      shared.LocaleKeys.reportPageExportButton,
                      track: shared.TrackConstants.reportPageTrack,
                    ) ??
                    'Export',
                icon: const Icon(Icons.download_rounded),
                onPressed: isExportable
                    ? () => _showExportModal(context, state)
                    : null,
              );
            },
          ),
          // Refresh
          IconButton(
            tooltip:
                context.tr(
                  shared.LocaleKeys.reportPageRefreshTooltip,
                  track: shared.TrackConstants.reportPageTrack,
                ) ??
                'Refresh Report',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (_range != null) {
                context.read<ReportsCubit>().loadReport(
                  widget.category.type,
                  _range!,
                  itemName: widget.category.filterItemName,
                );
              } else {
                context.read<ReportsCubit>().refresh(widget.category.type);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isDateFilterable)
            DateRangeFilterBar(onRangeChanged: _onRangeChanged)
          else
            const SizedBox.shrink(),
          Expanded(
            child: BlocBuilder<ReportsCubit, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return const shared.LoadingPage();
                }
                if (state is ReportsError) {
                  return shared.ErrorPage(
                    errorMsg: state.message,
                    onPressedRetryButton: () {
                      if (_range != null) {
                        context.read<ReportsCubit>().loadReport(
                          widget.category.type,
                          _range!,
                          itemName: widget.category.filterItemName,
                        );
                      } else {
                        context.read<ReportsCubit>().refresh(
                          widget.category.type,
                        );
                      }
                    },
                  );
                }

                return ValueListenableBuilder<bool>(
                  valueListenable: _isTableViewNotifier,
                  builder: (context, isTableView, _) {
                    if (isTableView) {
                      final exportData = _extractExportData(state, context);
                      if (exportData == null || exportData.rows.isEmpty) {
                        return const _EmptyChart();
                      }
                      return ReportDataTable(
                        headers: exportData.headers,
                        rows: exportData.rows,
                      );
                    }
                    return _buildChart(context, state, scheme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    ReportsState state,
    ColorScheme scheme,
  ) {
    return switch (widget.category.type) {
      ReportType.dailySales =>
        state is ReportsDailySalesLoaded
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: SalesLineChart(entries: state.entries),
              )
            : const _EmptyChart(),
      ReportType.monthlySales =>
        state is ReportsMonthlySalesLoaded
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: MonthlyBarChart(entries: state.entries),
              )
            : const _EmptyChart(),
      ReportType.topSellingItems =>
        state is ReportsTopItemsLoaded
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: TopItemsBarChart(items: state.items),
              )
            : const _EmptyChart(),
      ReportType.menuItemSales =>
        state is ReportsMenuItemSalesLoaded
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: MenuItemSalesBarChart(entries: state.entries),
              )
            : const _EmptyChart(),
      ReportType.paymentModes =>
        state is ReportsPaymentModesLoaded
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: PaymentModePieChart(entries: state.entries),
              )
            : const _EmptyChart(),
      ReportType.salesDashboard =>
        state is ReportsDashboardLoaded
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: DashboardKpiCard(dashboard: state.dashboard),
              )
            : const _EmptyChart(),
      ReportType.inventoryStock =>
        state is ReportsInventoryStockLoaded
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: InventoryStockBarChart(entries: state.entries),
              )
            : const _EmptyChart(),
      ReportType.purchases =>
        state is ReportsPurchasesLoaded
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: PurchaseSummaryBarChart(entries: state.entries),
              )
            : const _EmptyChart(),
      ReportType.expenditure =>
        state is ReportsExpenditureLoaded
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: ExpenditureSummaryPieChart(entries: state.entries),
              )
            : const _EmptyChart(),
    };
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.tr(
              shared.LocaleKeys.reportPageEmptyData,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'No data found for the selected range',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

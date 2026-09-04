import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:world_countries/world_countries.dart';

import '../../../../core/coozy_core.dart' as core;
import '../../../../shared/coozy_shared.dart' as shared;
import 'cubit/currency_exchange_cubit.dart';
import 'currency_exchange_actions.dart';

class CurrencyExchangeScreen extends StatefulWidget {
  const CurrencyExchangeScreen({super.key});

  @override
  State<CurrencyExchangeScreen> createState() => _CurrencyExchangeScreenState();
}

class _CurrencyExchangeScreenState extends State<CurrencyExchangeScreen>
    with CurrencyExchangeActions {
  late final TextEditingController _amountController;
  late final TextEditingController _searchController;
  late final FocusNode _amountFocusNode;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '1.0');
    _searchController = TextEditingController();
    _amountFocusNode = FocusNode();
    _searchFocusNode = FocusNode();

    _amountController.addListener(_onAmountChanged);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _searchController.removeListener(_onSearchChanged);
    _amountController.dispose();
    _searchController.dispose();
    _amountFocusNode.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _amountController.text.trim();
    final parsed = double.tryParse(text);
    if (parsed != null && parsed >= 0) {
      context.read<CurrencyExchangeCubit>().updateAmount(parsed);
    }
  }

  void _onSearchChanged() {
    context.read<CurrencyExchangeCubit>().updateSearchQuery(
      _searchController.text.trim(),
    );
  }

  /// Resolve FiatCurrency symbol and flag using world_countries package
  FiatCurrency? _resolveFiatCurrency(String code) {
    try {
      return FiatCurrency.maybeFromCode(code.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  String _getCurrencySymbol(String code) {
    final fiat = _resolveFiatCurrency(code);
    return fiat?.symbol ?? code.toUpperCase();
  }

  String _getCurrencyName(String code, Map<String, String> currenciesMap) {
    final fiat = _resolveFiatCurrency(code);
    if (fiat != null && fiat.name.isNotEmpty) {
      return fiat.name;
    }
    return currenciesMap[code.toLowerCase()] ?? code.toUpperCase();
  }

  String _formatMoney(double amount, String currencyCode) {
    return core.CurrencyFormatter.format(
      value: amount,
      currencyCode: currencyCode,
      position: core.CurrencySymbolPosition.prefix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) =>
          GetIt.instance<CurrencyExchangeCubit>()..loadExchangeData(),
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Currency Exchange & Rates'),
              actions: [
                BlocBuilder<CurrencyExchangeCubit, CurrencyExchangeState>(
                  builder: (context, state) {
                    if (state is CurrencyExchangeLoaded) {
                      return IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'Refresh Exchange Rates',
                        onPressed: () =>
                            onRefreshPressed(innerContext, state.baseCurrency),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            body: BlocBuilder<CurrencyExchangeCubit, CurrencyExchangeState>(
              builder: (context, state) {
                if (state is CurrencyExchangeLoading) {
                  return const shared.LoadingPage();
                } else if (state is CurrencyExchangeError) {
                  return shared.ErrorPage(
                    errorMsg: state.message,
                    onPressedRetryButton: () => innerContext
                        .read<CurrencyExchangeCubit>()
                        .loadExchangeData(forceRefresh: true),
                  );
                } else if (state is CurrencyExchangeLoaded) {
                  return _buildContent(innerContext, theme, isDark, state);
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    CurrencyExchangeLoaded state,
  ) {
    final filteredRates = state.rates.entries.where((entry) {
      final code = entry.key;
      final name = _getCurrencyName(code, state.currencies);
      final symbol = _getCurrencySymbol(code);
      final query = state.searchQuery.toLowerCase();
      return code.toLowerCase().contains(query) ||
          name.toLowerCase().contains(query) ||
          symbol.toLowerCase().contains(query);
    }).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Status Banner (Offline / Warm cache notification)
            if (state.isOffline)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.offline_pin_rounded,
                      color: Colors.amber.shade900,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Warm Data Mode: Displaying cached rates updated daily. (Last: ${state.date})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Calculator Main Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shared.ResponsiveLayout(
                      mobile: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Exchange Calculator',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Rates: ${state.date}',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      tablet: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Exchange Calculator',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Rates: ${state.date}',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      desktop: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Exchange Calculator',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Rates: ${state.date}',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount Input Field
                    TextFormField(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Enter Amount',
                        prefixIcon: Icon(
                          Icons.attach_money_rounded,
                          color: theme.primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Base & Target Dropdowns with Swap Button
                    Row(
                      children: [
                        // Base Currency Dropdown
                        Expanded(
                          child: _buildCurrencyDropdown(
                            context: context,
                            label: 'From (Base)',
                            value: state.baseCurrency,
                            currencies: state.currencies,
                            onChanged: (newVal) {
                              if (newVal != null) {
                                context
                                    .read<CurrencyExchangeCubit>()
                                    .changeBaseCurrency(newVal);
                              }
                            },
                          ),
                        ),

                        // Swap Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: IconButton.filledTonal(
                            onPressed: () => onSwapPressed(context),
                            icon: const Icon(Icons.swap_horiz_rounded),
                            tooltip: 'Swap Base & Target Currency',
                          ),
                        ),

                        // Target Currency Dropdown
                        Expanded(
                          child: _buildCurrencyDropdown(
                            context: context,
                            label: 'To (Target)',
                            value: state.targetCurrency,
                            currencies: state.currencies,
                            onChanged: (newVal) {
                              if (newVal != null) {
                                context
                                    .read<CurrencyExchangeCubit>()
                                    .changeTargetCurrency(newVal);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    // Converted Output Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_formatMoney(state.amount, state.baseCurrency)} =',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 18),
                                tooltip: 'Copy converted amount',
                                onPressed: () => copyToClipboard(
                                  context,
                                  _formatMoney(
                                    state.convertedAmount,
                                    state.targetCurrency,
                                  ),
                                  'Converted Amount',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            _formatMoney(
                              state.convertedAmount,
                              state.targetCurrency,
                            ),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '1 ${state.baseCurrency.toUpperCase()} = ${_formatMoney(state.targetRate, state.targetCurrency)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Spread & Market Rate Breakdown (Bid / Ask Spread)
                    ExpansionTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        'Market Spread (${state.spreadPercentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'Calculated Bid (Buy) & Ask (Sell) spread rates',
                        style: TextStyle(fontSize: 11),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text('Spread Margin: '),
                                  Expanded(
                                    child: Slider(
                                      value: state.spreadPercentage,
                                      min: 0.1,
                                      max: 5.0,
                                      divisions: 49,
                                      label:
                                          '${state.spreadPercentage.toStringAsFixed(1)}%',
                                      onChanged: (val) {
                                        context
                                            .read<CurrencyExchangeCubit>()
                                            .updateSpread(val);
                                      },
                                    ),
                                  ),
                                  Text(
                                    '${state.spreadPercentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSpreadCard(
                                      title: 'Bid Price (Buy Rate)',
                                      rate: state.bidRate,
                                      total: state.bidAmount,
                                      targetCurrency: state.targetCurrency,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildSpreadCard(
                                      title: 'Ask Price (Sell Rate)',
                                      rate: state.askRate,
                                      total: state.askAmount,
                                      targetCurrency: state.targetCurrency,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Live Rates Section Header & Search
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Exchange Rates (Base: ${state.baseCurrency.toUpperCase()})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${filteredRates.length} Currencies',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Search Bar
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) {
                context.read<CurrencyExchangeCubit>().updateSearchQuery(
                  val.trim(),
                );
              },
              decoration: InputDecoration(
                hintText: 'Search currency code or name (e.g. EUR, Rupee)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<CurrencyExchangeCubit>()
                              .updateSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 14),

            // Rates Grid View
            if (filteredRates.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'No currencies match your search.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 900
                      ? 4
                      : MediaQuery.of(context).size.width > 600
                      ? 3
                      : 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredRates.length,
                itemBuilder: (context, index) {
                  final entry = filteredRates[index];
                  final code = entry.key;
                  final rate = entry.value;
                  final symbol = _getCurrencySymbol(code);
                  final name = _getCurrencyName(code, state.currencies);
                  final converted = state.amount * rate;

                  final isSelected =
                      code.toLowerCase() == state.targetCurrency.toLowerCase();

                  return Card(
                    elevation: isSelected ? 3 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.transparent,
                        width: isSelected ? 2 : 0,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context
                            .read<CurrencyExchangeCubit>()
                            .changeTargetCurrency(code);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: theme.primaryColor
                                      .withValues(alpha: 0.15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        symbol.length <= 4
                                            ? symbol
                                            : code.toUpperCase(),
                                        maxLines: 1,
                                        softWrap: false,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    code.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatMoney(converted, code),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required BuildContext context,
    required String label,
    required String value,
    required Map<String, String> currencies,
    required ValueChanged<String?> onChanged,
  }) {
    final currencyEntries = currencies.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return DropdownButtonFormField<String>(
      initialValue: value.toLowerCase(),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: currencyEntries.map((entry) {
        final code = entry.key;
        final name = _getCurrencyName(code, currencies);
        final symbol = _getCurrencySymbol(code);
        return DropdownMenuItem<String>(
          value: code.toLowerCase(),
          child: Row(
            children: [
              Text(
                '[$symbol] ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: Text(
                  '${code.toUpperCase()} - $name',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSpreadCard({
    required String title,
    required double rate,
    required double total,
    required String targetCurrency,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rate: ${rate.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            _formatMoney(total, targetCurrency),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

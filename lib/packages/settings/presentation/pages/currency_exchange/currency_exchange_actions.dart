import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/currency_exchange_cubit.dart';

mixin CurrencyExchangeActions {
  void onSwapPressed(BuildContext context) {
    context.read<CurrencyExchangeCubit>().swapCurrencies();
  }

  void onRefreshPressed(BuildContext context, String baseCurrency) {
    context.read<CurrencyExchangeCubit>().loadExchangeData(
          baseCurrency: baseCurrency,
          forceRefresh: true,
        );
  }

  void copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

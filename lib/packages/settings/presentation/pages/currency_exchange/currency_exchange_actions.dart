import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
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
    shared.SnackBarUtils.showSuccess(
      context,
      message: '$label copied to clipboard!',
      duration: const Duration(seconds: 2),
    );
  }
}

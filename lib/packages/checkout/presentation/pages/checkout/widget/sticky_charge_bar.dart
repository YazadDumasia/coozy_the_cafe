import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/checkout_bloc.dart';
import '../../../utils/responsive_modal.dart';
import 'payment_sheet_modal.dart';

class StickyChargeBar extends StatelessWidget {
  const StickyChargeBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        final grandTotal = state.summary.grandTotal;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: SafeArea(
            top: false,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
              ),
              onPressed: () async {
                await showResponsiveModal(
                  context: context,
                  title: 'PAYMENT',
                  child: const PaymentSheetModal(),
                );
                if (context.mounted) {
                  final bloc = context.read<CheckoutBloc>();
                  if (bloc.state.cartItems.isEmpty) {
                    context.go(core.AppRoutePath.homeRoute);
                  }
                }
              },
              child: Text(
                'Charge: ${core.CurrencyFormatter.format(value: grandTotal)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ).inExpandedRow(),
          ),
        );
      },
    );
  }
}

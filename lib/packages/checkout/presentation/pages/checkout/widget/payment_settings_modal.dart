import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/checkout_bloc.dart';

class PaymentSettingsModal extends StatelessWidget {
  final VoidCallback onOpenAddNew;

  const PaymentSettingsModal({super.key, required this.onOpenAddNew});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'PAYMENT SETTINGS',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.availablePaymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = state.availablePaymentMethods[index];
                    return SwitchListTile(
                      secondary: Icon(method.icon, color: theme.colorScheme.primary),
                      title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      value: method.isEnabled,
                      onChanged: (_) {
                        context.read<CheckoutBloc>().add(CheckoutPaymentMethodToggled(method.id));
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  '+ ADD NEW PAYMENT MODE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onOpenAddNew();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

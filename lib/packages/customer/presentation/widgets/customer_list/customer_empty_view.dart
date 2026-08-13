import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

/// Displayed when there are no customers at all (not searching).
class CustomerEmptyView extends StatelessWidget {
  final VoidCallback onAddCustomer;

  const CustomerEmptyView({super.key, required this.onAddCustomer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            shared.MenuIcons.menuEmptyPlaceholder,
            color: Theme.of(context).colorScheme.primary,
            size: 110,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(
                  shared.LocaleKeys.noCustomersFoundMsg,
                  track: shared.TrackConstants.menuSubCategoryPageTrack,
                ) ??
                'No customers found.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ).inExpandedRow(),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onAddCustomer,
            icon: const Icon(Icons.add),
            label: Text(
              context.tr(
                    shared.LocaleKeys.addCustomerBtn,
                    track: shared.TrackConstants.menuCategoryPageTrack,
                  ) ??
                  'Add Customer',
            ),
          ),
        ],
      ),
    );
  }
}

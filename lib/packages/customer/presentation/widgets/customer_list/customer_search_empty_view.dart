import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

/// Displayed when a search query returns no matching customers.
class CustomerSearchEmptyView extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClearSearch;

  const CustomerSearchEmptyView({
    super.key,
    required this.searchQuery,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 110,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(
                  shared.LocaleKeys.noCustomersFoundMsg,
                  track: shared.TrackConstants.customerPageTrack,
                ) ??
                'No customers found.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ).inExpandedRow(),

          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onClearSearch,
            icon: const Icon(Icons.clear),
            label: Text(
              context.tr(
                    shared.LocaleKeys.customersSearchHintText,
                    track: shared.TrackConstants.customerPageTrack,
                  ) ??
                  'Clear Search',
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/coozy_shared.dart' as shared;
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../widgets/add_edit_customer_bottom_sheet.dart';

class CustomerListScreenActions {
  static void onScroll(
    BuildContext context,
    ScrollController scrollController,
  ) {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) {
      context.read<CustomerBloc>().add(const LoadCustomers());
    }
  }

  static void onSearchChanged(BuildContext context, String query) {
    context.read<CustomerBloc>().add(
      LoadCustomers(isRefresh: true, searchQuery: query),
    );
  }

  static void showAddEditForm(
    BuildContext context, [
    CustomerEntity? customer,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: context.read<CustomerBloc>(),
        child: AddEditCustomerBottomSheet(customer: customer),
      ),
    );
  }

  static void deleteCustomer(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.tr(
                shared.LocaleKeys.customerDialogDeleteTitle,
                track: shared.TrackConstants.customerPageTrack,
              ) ??
              'Delete Customer?',
        ),
        content: Text(
          context.tr(
                shared.LocaleKeys.customerDialogDeleteSubTitle,
                track: shared.TrackConstants.customerPageTrack,
              ) ??
              'Are you sure you want to delete this customer?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr(
                    shared.LocaleKeys.commonCancel,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CustomerBloc>().add(
                DeleteCustomer(
                  id,
                  onSuccess: () {
                    if (context.mounted) {
                      shared.DialogUtils.showAutoDismissDialog(
                        context: context,
                        title: context.tr(
                          shared.LocaleKeys.commonSuccess,
                          track: shared.TrackConstants.commonTrack,
                        ) ?? 'Success',
                        descriptions: context.tr(
                          shared.LocaleKeys.crudSuccessDelete,
                          track: shared.TrackConstants.commonTrack,
                        ) ?? 'Record deleted successfully.',
                        titleIcon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 50,
                        ),
                      );
                    }
                  },
                  onError: (error) {
                    if (context.mounted) {
                      shared.DialogUtils.showAutoDismissDialog(
                        context: context,
                        title: context.tr(
                          shared.LocaleKeys.commonError,
                          track: shared.TrackConstants.commonTrack,
                        ) ?? 'Error',
                        descriptions: error.isNotEmpty
                            ? error
                            : (context.tr(
                                shared.LocaleKeys.commonErrorMsg,
                                track: shared.TrackConstants.commonTrack,
                              ) ?? 'An error occurred.'),
                        titleIcon: const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 50,
                        ),
                      );
                    }
                  },
                ),
              );
            },
            child: Text(
              context.tr(
                    shared.LocaleKeys.commonDelete,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

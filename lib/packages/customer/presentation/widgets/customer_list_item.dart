import 'package:flutter/material.dart';
import '../../../shared/coozy_shared.dart' as shared;
import '../../domain/entities/customer_entity.dart';
import '../pages/customer_list_screen_actions.dart';

class CustomerListItem extends StatelessWidget {
  final CustomerEntity customer;

  const CustomerListItem({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            customer.name?.isNotEmpty == true
                ? customer.name![0].toUpperCase()
                : '?',
          ),
        ),
        title: Text(
          customer.name ??
              context.tr(
                shared.LocaleKeys.commonUnknown,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Unknown',
        ),
        subtitle: Builder(
          builder: (context) {
            final phone = customer.phoneNumber ?? '';
            final isoCode = customer.isoCode ?? '';
            if (phone.isEmpty) {
              return Text(
                context.tr(
                      shared.LocaleKeys.commonNoPhone,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'No Phone',
              );
            }
            String phonePrefix = '';
            if (isoCode.isNotEmpty) {
              if (isoCode.startsWith('+')) {
                phonePrefix = isoCode;
              } else {
                try {
                  final country =
                      shared.CountryPickerUtils.getCountryByIsoCode(isoCode);
                  phonePrefix = '+${country.phoneCode}';
                } catch (_) {
                  phonePrefix = isoCode;
                }
              }
            }
            final displayPhone =
                phonePrefix.isNotEmpty ? '$phonePrefix $phone' : phone;
            return Text(displayPhone);
          },
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              CustomerListScreenActions.showAddEditForm(context, customer);
            } else if (value == 'delete') {
              if (customer.id != null) {
                CustomerListScreenActions.deleteCustomer(context, customer.id!);
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonEdit,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Edit',
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonDelete,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Delete',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

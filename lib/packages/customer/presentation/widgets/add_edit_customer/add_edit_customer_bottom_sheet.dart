import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../bloc/customer_bloc.dart';

class AddEditCustomerBottomSheet extends StatefulWidget {
  final CustomerEntity? customer;

  const AddEditCustomerBottomSheet({super.key, this.customer});

  @override
  State<AddEditCustomerBottomSheet> createState() =>
      _AddEditCustomerBottomSheetState();
}

class _AddEditCustomerBottomSheetState
    extends State<AddEditCustomerBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final FocusNode _phoneFocusNode = FocusNode();
  String? _isoCode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.customer?.phoneNumber ?? '',
    );

    String? isoCode = widget.customer?.isoCode;

    // Fallback: parse complete phone number if isoCode is missing in existing record
    final phone = widget.customer?.phoneNumber ?? '';
    if ((isoCode == null || isoCode.isEmpty) && phone.isNotEmpty) {
      final parsed = shared.PhoneNumber.fromCompleteNumber(
        completeNumber: phone.startsWith('+') ? phone : '+$phone',
      );
      if (parsed.countryISOCode.isNotEmpty) {
        isoCode = parsed.countryISOCode;
      }
    }

    _isoCode = isoCode ?? 'IN';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      if (widget.customer == null) {
        // Add
        final newCustomer = CustomerEntity(
          name: name,
          phoneNumber: phone,
          isoCode: _isoCode,
          createdDate: DateTime.now().toIso8601String(),
        );
        context.read<CustomerBloc>().add(
          AddCustomer(
            newCustomer,
            onSuccess: () {
              Navigator.pop(context);
              shared.DialogUtils.showAutoDismissDialog(
                context: context,
                title:
                    context.tr(
                      shared.LocaleKeys.commonSuccess,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Success',
                descriptions:
                    context.tr(
                      shared.LocaleKeys.customerAddSuccess,
                      track: shared.TrackConstants.customerPageTrack,
                    ) ??
                    (context.tr(
                          shared.LocaleKeys.crudSuccessAdd,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Customer added successfully.'),
                titleIcon: Lottie.asset(
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Assets.lottie.doneLightBrownColor
                      : Assets.lottie.doneBrownColor,
                  repeat: false,
                ),
              );
            },
            onError: (error) {
              core.PlatformUtils.debugLog(
                AddEditCustomerBottomSheet,
                'AddCustomer:onError: $error',
              );
              Navigator.pop(context);
              shared.DialogUtils.showAutoDismissDialog(
                context: context,
                title:
                    context.tr(
                      shared.LocaleKeys.commonError,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Error',
                descriptions: error.isNotEmpty
                    ? error
                    : (context.tr(
                            shared.LocaleKeys.commonErrorMsg,
                            track: shared.TrackConstants.commonTrack,
                          ) ??
                          'Something when wrong. Please try again.'),
                titleIcon: Lottie.asset(
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Assets.lottie.errorLightLoaderIcon
                      : Assets.lottie.errorDarkLoaderIcon,
                  repeat: false,
                ),
              );
            },
          ),
        );
      } else {
        // Edit
        final updatedCustomer = widget.customer!.copyWith(
          name: name,
          phoneNumber: phone,
          isoCode: _isoCode,
        );
        context.read<CustomerBloc>().add(
          UpdateCustomer(
            updatedCustomer,
            onSuccess: () {
              Navigator.pop(context);
              shared.DialogUtils.showAutoDismissDialog(
                context: context,
                title:
                    context.tr(
                      shared.LocaleKeys.commonSuccess,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Success',
                descriptions:
                    context.tr(
                      shared.LocaleKeys.customerUpdateSuccess,
                      track: shared.TrackConstants.customerPageTrack,
                    ) ??
                    (context.tr(
                          shared.LocaleKeys.crudSuccessUpdate,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Customer updated successfully.'),
                titleIcon: Lottie.asset(
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Assets.lottie.doneLightBrownColor
                      : Assets.lottie.doneBrownColor,
                  repeat: false,
                ),
              );
            },
            onError: (error) {
              core.PlatformUtils.debugLog(
                AddEditCustomerBottomSheet,
                'UpdateCustomer:onError: $error',
              );
              Navigator.pop(context);
              shared.DialogUtils.showAutoDismissDialog(
                context: context,
                title:
                    context.tr(
                      shared.LocaleKeys.commonError,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Error',
                descriptions: error.isNotEmpty
                    ? error
                    : (context.tr(
                            shared.LocaleKeys.commonErrorMsg,
                            track: shared.TrackConstants.commonTrack,
                          ) ??
                          'Something when wrong. Please try again.'),
                titleIcon: Lottie.asset(
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Assets.lottie.errorLightLoaderIcon
                      : Assets.lottie.errorDarkLoaderIcon,
                  repeat: false,
                ),
              );
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit
                    ? context.tr(
                            shared.LocaleKeys.editCustomerTitle,
                            track: shared.TrackConstants.customerPageTrack,
                          ) ??
                          'Edit Customer'
                    : context.tr(
                            shared.LocaleKeys.addCustomerTitle,
                            track: shared.TrackConstants.customerPageTrack,
                          ) ??
                          'Add Customer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText:
                      context.tr(
                        shared.LocaleKeys.commonName,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return context.tr(
                          shared.LocaleKeys.commonNameIsRequired,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              shared.PhoneNumberTextFormField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                showDropdownIcon: true,
                showCountryFlag: true,
                initialCountryCode: _isoCode ?? 'IN',
                flagsButtonMargin: const EdgeInsets.all(10),
                isCountryButtonPersistent: false,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText:
                      context.tr(
                        shared.LocaleKeys.commonPhoneNumberLabel,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Phone Number',
                  hintText:
                      context.tr(
                        shared.LocaleKeys.commonPhoneNumberOptionalHint,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Phone Number (Optional)',
                  border: const OutlineInputBorder(),
                ),
                onCountryChanged: (shared.Country country) {
                  setState(() {
                    _isoCode = country.isoCode;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  isEdit
                      ? context.tr(
                              shared.LocaleKeys.saveChangesBtn,
                              track: shared.TrackConstants.customerPageTrack,
                            ) ??
                            'Save Changes'
                      : context.tr(
                              shared.LocaleKeys.addCustomerBtn,
                              track: shared.TrackConstants.customerPageTrack,
                            ) ??
                            'Add Customer',
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

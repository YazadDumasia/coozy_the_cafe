import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/core/di/injection_container.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../domain/entities/business_profile_entity.dart';
import 'business_profile_actions.dart';
import 'cubit/business_profile_cubit.dart';
import 'widget/business_logo_picker_card.dart';
import 'widget/business_profile_empty_view.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BusinessProfileCubit>(
      create: (context) => sl<BusinessProfileCubit>()..loadProfile(),
      child: const _BusinessProfileView(),
    );
  }
}

class _BusinessProfileView extends StatefulWidget {
  const _BusinessProfileView();

  @override
  State<_BusinessProfileView> createState() => _BusinessProfileViewState();
}

class _BusinessProfileViewState extends State<_BusinessProfileView> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _secondaryPhoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _mapsUrlController;
  late final TextEditingController _websiteController;
  late final TextEditingController _instagramController;
  late final TextEditingController _receiptFooterController;

  // Focus Nodes
  late final FocusNode _nameFocusNode;
  late final FocusNode _addressFocusNode;
  late final FocusNode _phoneFocusNode;
  late final FocusNode _secondaryPhoneFocusNode;
  late final FocusNode _emailFocusNode;
  late final FocusNode _mapsUrlFocusNode;
  late final FocusNode _websiteFocusNode;
  late final FocusNode _instagramFocusNode;
  late final FocusNode _receiptFooterFocusNode;

  // ValueNotifier for custom logo path & form state
  late final ValueNotifier<String?> _logoPathNotifier;
  late final ValueNotifier<bool> _isSavingNotifier;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _secondaryPhoneController = TextEditingController();
    _emailController = TextEditingController();
    _mapsUrlController = TextEditingController();
    _websiteController = TextEditingController();
    _instagramController = TextEditingController();
    _receiptFooterController = TextEditingController();

    _nameFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _secondaryPhoneFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _mapsUrlFocusNode = FocusNode();
    _websiteFocusNode = FocusNode();
    _instagramFocusNode = FocusNode();
    _receiptFooterFocusNode = FocusNode();

    _logoPathNotifier = ValueNotifier<String?>(null);
    _isSavingNotifier = ValueNotifier<bool>(false);
  }

  void _populateForm(BusinessProfileEntity profile) {
    _nameController.text = profile.cafeName;
    _addressController.text = profile.address;
    _phoneController.text = profile.phone;
    _secondaryPhoneController.text = profile.secondaryPhone ?? '';
    _emailController.text = profile.email ?? '';
    _mapsUrlController.text = profile.googleMapsUrl ?? '';
    _websiteController.text = profile.websiteUrl ?? '';
    _instagramController.text = profile.instagramUrl ?? '';
    _receiptFooterController.text = profile.receiptFooterMessage ?? '';
    _logoPathNotifier.value = profile.logoPath;
  }

  void _onSave(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProfile = BusinessProfileEntity(
        cafeName: _nameController.text.trim(),
        logoPath: _logoPathNotifier.value,
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        secondaryPhone: _secondaryPhoneController.text.trim().isEmpty
            ? null
            : _secondaryPhoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        googleMapsUrl: _mapsUrlController.text.trim().isEmpty
            ? null
            : _mapsUrlController.text.trim(),
        websiteUrl: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        instagramUrl: _instagramController.text.trim().isEmpty
            ? null
            : _instagramController.text.trim(),
        receiptFooterMessage: _receiptFooterController.text.trim().isEmpty
            ? null
            : _receiptFooterController.text.trim(),
      );

      context.read<BusinessProfileCubit>().updateProfile(updatedProfile);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _secondaryPhoneController.dispose();
    _emailController.dispose();
    _mapsUrlController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _receiptFooterController.dispose();

    _nameFocusNode.dispose();
    _addressFocusNode.dispose();
    _phoneFocusNode.dispose();
    _secondaryPhoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _mapsUrlFocusNode.dispose();
    _websiteFocusNode.dispose();
    _instagramFocusNode.dispose();
    _receiptFooterFocusNode.dispose();

    _logoPathNotifier.dispose();
    _isSavingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(
                shared.LocaleKeys.settingsBusinessProfileTitle,
                track: shared.TrackConstants.settingTrack,
              ) ??
              'Business Profile',
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isSavingNotifier,
            builder: (context, isSaving, _) {
              if (isSaving) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                );
              }
              return IconButton(
                tooltip: 'Save Profile',
                icon: const Icon(Icons.check_rounded),
                onPressed: () => _onSave(context),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<BusinessProfileCubit, BusinessProfileState>(
        listener: (context, state) {
          if (state is BusinessProfileSaving) {
            _isSavingNotifier.value = true;
          } else {
            _isSavingNotifier.value = false;
          }

          if (state is BusinessProfileLoaded) {
            _populateForm(state.profile);
          } else if (state is BusinessProfileSavedSuccess) {
            _populateForm(state.profile);
            shared.SnackBarUtils.showSuccess(
              context,
              message:
                  context.tr(
                    shared.LocaleKeys.settingsBusinessProfileSavedSuccess,
                    track: shared.TrackConstants.settingTrack,
                  ) ??
                  'Business profile updated successfully!',
            );
          } else if (state is BusinessProfileError) {
            shared.SnackBarUtils.showError(
              context,
              message: state.errorMessage,
            );
          }
        },
        builder: (context, state) {
          if (state is BusinessProfileInitial ||
              state is BusinessProfileLoading) {
            return const shared.LoadingPage();
          }

          if (state is BusinessProfileError) {
            return BusinessProfileEmptyView(
              onRetry: () =>
                  context.read<BusinessProfileCubit>().loadProfile(),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 900 : double.infinity,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Logo Section
                    BusinessLogoPickerCard(
                      logoPathNotifier: _logoPathNotifier,
                      onLogoChanged: (newPath) {
                        _logoPathNotifier.value = newPath;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Section 1: Business & Contact Info
                    _buildSectionHeader(
                      context,
                      title:
                          context.tr(
                            shared
                                .LocaleKeys
                                .settingsBusinessProfileInfoSection,
                            track: shared.TrackConstants.settingTrack,
                          ) ??
                          'Business & Contact Info',
                      icon: Icons.storefront_rounded,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileNameLabel,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'Business / Cafe Name',
                                hintText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileNameHint,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'Enter cafe or restaurant name',
                                prefixIcon: const Icon(Icons.business_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Business name cannot be empty';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _addressController,
                              focusNode: _addressFocusNode,
                              maxLines: 3,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 16.0,
                                ),
                                labelText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileAddressLabel,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'Cafe Address',
                                hintText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileAddressHint,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'Enter full street address, city, postal code',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 40.0),
                                  child: Icon(Icons.location_on_rounded),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Address cannot be empty';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfilePhoneLabel,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'Primary Phone Number',
                                hintText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfilePhoneHint,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'e.g. +91 9974776639',
                                prefixIcon: const Icon(Icons.phone_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Phone number cannot be empty';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _secondaryPhoneController,
                              focusNode: _secondaryPhoneFocusNode,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileSecondaryPhoneLabel,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'Secondary Phone Number',
                                hintText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileSecondaryPhoneHint,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'e.g. +91 9725002491 (Optional)',
                                prefixIcon: const Icon(Icons.phone_iphone_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileEmailLabel,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'Email Address',
                                hintText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileEmailHint,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'e.g. contact@coozythecafe.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Online Presence & Location
                    _buildSectionHeader(
                      context,
                      title:
                          context.tr(
                            shared
                                .LocaleKeys
                                .settingsBusinessProfileOnlineSection,
                            track: shared.TrackConstants.settingTrack,
                          ) ??
                          'Online Presence & Location',
                      icon: Icons.public_rounded,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _mapsUrlController,
                              focusNode: _mapsUrlFocusNode,
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileMapsLabel,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'Google Maps Link',
                                hintText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileMapsHint,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'e.g. https://maps.app.goo.gl/...',
                                prefixIcon: const Icon(Icons.map_outlined),
                                suffixIcon: IconButton(
                                  tooltip:
                                      context.tr(
                                        shared
                                            .LocaleKeys
                                            .settingsBusinessProfileOpenMaps,
                                        track:
                                            shared.TrackConstants.settingTrack,
                                      ) ??
                                      'Test Maps Link',
                                  icon: const Icon(Icons.open_in_new_rounded),
                                  onPressed: () =>
                                      BusinessProfileActions.launchMapsUrl(
                                        context,
                                        _mapsUrlController.text,
                                      ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _websiteController,
                              focusNode: _websiteFocusNode,
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileWebsiteLabel,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'Website URL',
                                hintText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileWebsiteHint,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'e.g. https://coozythecafe.com',
                                prefixIcon: const Icon(Icons.language_rounded),
                                suffixIcon: IconButton(
                                  tooltip: 'Open Website',
                                  icon: const Icon(Icons.open_in_new_rounded),
                                  onPressed: () =>
                                      BusinessProfileActions.launchExternalUrl(
                                        context,
                                        _websiteController.text,
                                      ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _instagramController,
                              focusNode: _instagramFocusNode,
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileInstagramLabel,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'Instagram Handle / URL',
                                hintText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileInstagramHint,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'e.g. https://instagram.com/coozy_the_cafe',
                                prefixIcon: const Icon(Icons.camera_alt_outlined),
                                suffixIcon: IconButton(
                                  tooltip: 'Open Instagram',
                                  icon: const Icon(Icons.open_in_new_rounded),
                                  onPressed: () =>
                                      BusinessProfileActions.launchExternalUrl(
                                        context,
                                        _instagramController.text,
                                      ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Receipt & Invoicing Footer
                    _buildSectionHeader(
                      context,
                      title:
                          context.tr(
                            shared
                                .LocaleKeys
                                .settingsBusinessProfileReceiptSection,
                            track: shared.TrackConstants.settingTrack,
                          ) ??
                          'Receipt & Invoicing Footer',
                      icon: Icons.receipt_long_rounded,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _receiptFooterController,
                              focusNode: _receiptFooterFocusNode,
                              maxLines: 2,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 16.0,
                                ),
                                labelText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileFooterLabel,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'Receipt Footer Greeting / Note',
                                hintText:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .settingsBusinessProfileFooterHint,
                                      track: shared.TrackConstants.settingTrack,
                                    ) ??
                                    'e.g. Thank you for dining with us! Please visit again.',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 24.0),
                                  child: Icon(Icons.chat_bubble_outline_rounded),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      height: 50,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isSavingNotifier,
                        builder: (context, isSaving, _) {
                          return ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isSaving ? null : () => _onSave(context),
                            icon: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: Text(
                              isSaving ? 'Saving Changes...' : 'Save Profile',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

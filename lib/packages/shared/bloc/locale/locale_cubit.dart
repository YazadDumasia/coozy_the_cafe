import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/language_preferences.dart';
import '../../coozy_shared.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en')) {
    _loadPreferredLocale(); // Load the saved locale on initialization
  }
  final List<LanguageModel> languages = LanguageModel.getLanguages();

  Future<void> _loadPreferredLocale() async {
    final String languageCode = await LanguagePreferences.getLanguageCode();
    final LanguageModel languageModel = languages.firstWhere(
      (lang) => lang.code == languageCode,
      orElse: () => LanguageModel.getLanguages().first,
    ); // Fallback to first language if not found

    emit(_localeFromLanguageModel(languageModel));
  }

  void changeLocale(LanguageModel languageModel) {
    LanguagePreferences.setLanguageCode(languageModel.code!);
    emit(_localeFromLanguageModel(languageModel));
  }

  Locale _localeFromLanguageModel(LanguageModel languageModel) {
    return languageModel.countryCode != null
        ? Locale(languageModel.code!, languageModel.countryCode)
        : Locale(languageModel.code!);
  }
}

import 'dart:convert';
import 'language_preferences.dart' as prefs;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../coozy_shared.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this.language);
  final Locale? locale;
  LanguageModel? language;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, dynamic>? _localizedStrings;

  Future<bool> load() async {
    final String jsonString = await rootBundle.loadString(
      'assets/locale/${language!.file}',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = {};

    // Recursively flatten the JSON map for O(1) lookups
    void flattenMap(Map<String, dynamic> map, [String? prefix]) {
      map.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          flattenMap(v, prefix == null ? k : '$prefix.$k');
        } else {
          final value = v.toString();
          if (prefix != null) {
            _localizedStrings!['$prefix.$k'] = value;
          }
          _localizedStrings![k] = value;
        }
      });
    }

    flattenMap(jsonMap);

    return true;
  }

  String? translate(
    String key, {
    Map<String, String>? params,
    final String? track,
  }) {
    if (_localizedStrings == null) {
      // Constants.debugLog(AppLocalizations, 'Please check json file path.');
      return null;
    }

    String? translated;

    if (track != null && _localizedStrings!.containsKey('$track.$key')) {
      translated = _localizedStrings!['$track.$key'];
    } else {
      translated = _localizedStrings![key];
    }

    if (translated == null) {
      return null;
    }

    // Replace params like ${tableName} with actual values
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        translated = translated?.replaceAll('\${$paramKey}', paramValue);
      });
    }

    return translated;
  }

  static String getCurrentLanguageCode(BuildContext context) {
    final AppLocalizations? appLocalizations = AppLocalizations.of(context);

    if (appLocalizations != null) {
      final String? currentLanguageCode = appLocalizations.locale?.languageCode;
      return currentLanguageCode ??
          'en'; // Default to "en" if the language code is not available
    } else {
      return 'en'; // Default to "en" if AppLocalizations instance is not available
    }
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate(this.languages);
  final List<LanguageModel> languages;

  @override
  bool isSupported(Locale locale) {
    return languages
        .map((language) => language.code)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final String languageCode =
        await prefs.LanguagePreferences.getLanguageCode();
    final LanguageModel language = languages.firstWhere(
      (language) => language.code == languageCode,
      orElse: () => languages.firstWhere((language) => language.code == 'en'),
    );

    final AppLocalizations localizations = AppLocalizations(locale, language);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}

//
// AppLocalizations.of(context).translate('Key_name'),

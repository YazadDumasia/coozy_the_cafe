import '../utils/components/local_keys_enum.dart' as keys;
import '../utils/components/local_manager.dart' as mag;

class LanguagePreferences {
  // static const String _key = 'user_language';

  static Future<String> getLanguageCode() async {
    final String? data = mag.LocalManager.instance.getLocaleKeys(
      key: keys.PreferencesKeys.userLanguage,
    );
    return data ?? 'en';
  }

  static Future<void> setLanguageCode(String languageCode) async {
    await mag.LocalManager.instance.setLocaleKeys(
      key: keys.PreferencesKeys.userLanguage,
      value: languageCode,
    );
  }
}

import 'local_keys_enum.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalManager {
  LocalManager._init() {
    SharedPreferences.getInstance().then((value) => _preferences = value);
  }
  SharedPreferences? _preferences;

  static final LocalManager _instance = LocalManager._init();

  static LocalManager get instance => _instance;

  static Future preferencesInit() async {
    _instance._preferences = await SharedPreferences.getInstance();
  }

  Future<void> clearAll() async {
    final String? userLanguage = getLocaleKeys(
      key: PreferencesKeys.userLanguage,
    );
    // await DatabaseHelper.instance.clearDatabase();
    await _preferences!.clear();
    await DefaultCacheManager().emptyCache();
    await setLocaleKeys(key: PreferencesKeys.userLanguage, value: userLanguage);
    await setBoolValue(key: PreferencesKeys.appEnableDarkTheme, value: false);
    await setBoolValue(key: PreferencesKeys.isFirstApp, value: false);
    await setBoolValue(key: PreferencesKeys.isLoggedIn, value: false);
    await setBoolValue(key: PreferencesKeys.commonFirstTime, value: false);
    await setBoolValue(key: PreferencesKeys.appEnableDarkTheme, value: false);
  }

  Future<void> clearAllSaveFirst() async {
    if (_preferences != null) {
      // bool theme_flag=getBoolValue(PreferencesKeys.appEnableDarkTheme);
      final String? userLanguage = getLocaleKeys(
        key: PreferencesKeys.userLanguage,
      );
      await _preferences!.clear();
      await DefaultCacheManager().emptyCache();
      await setLocaleKeys(
        key: PreferencesKeys.userLanguage,
        value: userLanguage,
      );
      await setBoolValue(key: PreferencesKeys.isFirstApp, value: true);
      await setBoolValue(key: PreferencesKeys.isLoggedIn, value: false);
      await setBoolValue(key: PreferencesKeys.commonFirstTime, value: false);
      await setBoolValue(key: PreferencesKeys.appEnableDarkTheme, value: false);
    }
  }

  Future<void> setLocaleKeys({
    required PreferencesKeys key,
    required String? value,
  }) async {
    await _preferences!.setString(key.toString(), value ?? '');
  }

  String? getLocaleKeys({required PreferencesKeys key}) =>
      _preferences?.getString(key.toString()) ?? '';

  Future<void> setIntValue({required PreferencesKeys key, int? value}) async {
    await _preferences!.setInt(key.toString(), value ?? 0);
  }

  int? getIntValue({required PreferencesKeys key}) =>
      _preferences?.getInt(key.toString());

  Future<void> setDoubleValue({
    required PreferencesKeys key,
    required double? value,
  }) async {
    await _preferences!.setDouble(key.toString(), value ?? 0.0);
  }

  double? getDoubleValue({required PreferencesKeys key}) =>
      _preferences?.getDouble(key.toString());

  Future<void> setBoolValue({
    required PreferencesKeys key,
    required bool value,
  }) async {
    await _preferences!.setBool(key.toString(), value);
  }

  bool getBoolValue({required PreferencesKeys? key}) =>
      _preferences?.getBool(key.toString()) ?? false;

  bool get isLoggedIn => getBoolValue(key: PreferencesKeys.isLoggedIn);

  set isLoggedIn(bool value) =>
      setBoolValue(key: PreferencesKeys.isLoggedIn, value: value);
}

//await LocalManager.instance.setLocaleKeys(
//   key: PreferencesKeys.USER_NAME,
//   value: "John Doe",
// );

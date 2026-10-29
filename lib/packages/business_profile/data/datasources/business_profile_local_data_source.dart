import 'package:shared_preferences/shared_preferences.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../domain/entities/business_profile_entity.dart';

abstract class BusinessProfileLocalDataSource {
  Future<BusinessProfileEntity> getBusinessProfile();
  Future<void> saveBusinessProfile(BusinessProfileEntity profile);
}

class BusinessProfileLocalDataSourceImpl
    implements BusinessProfileLocalDataSource {
  final SharedPreferences? sharedPreferences;

  BusinessProfileLocalDataSourceImpl({this.sharedPreferences});

  Future<SharedPreferences> _getPrefs() async {
    return sharedPreferences ?? await SharedPreferences.getInstance();
  }

  @override
  Future<BusinessProfileEntity> getBusinessProfile() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(
      shared.PreferencesKeys.businessProfileInfo.name,
    );
    if (jsonStr != null && jsonStr.isNotEmpty) {
      return BusinessProfileEntity.fromJson(jsonStr);
    }
    return BusinessProfileEntity.defaultProfile();
  }

  @override
  Future<void> saveBusinessProfile(BusinessProfileEntity profile) async {
    final prefs = await _getPrefs();
    await prefs.setString(
      shared.PreferencesKeys.businessProfileInfo.name,
      profile.toJson(),
    );
  }
}

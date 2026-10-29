import 'package:shared_preferences/shared_preferences.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../domain/entities/business_profile_entity.dart';

abstract class BusinessProfileLocalDataSource {
  Future<BusinessProfileEntity> getBusinessProfile();
  Future<void> saveBusinessProfile(BusinessProfileEntity profile);
}

class BusinessProfileLocalDataSourceImpl
    implements BusinessProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  BusinessProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<BusinessProfileEntity> getBusinessProfile() async {
    final jsonStr = sharedPreferences.getString(
      shared.PreferencesKeys.businessProfileInfo.name,
    );
    if (jsonStr != null && jsonStr.isNotEmpty) {
      return BusinessProfileEntity.fromJson(jsonStr);
    }
    return BusinessProfileEntity.defaultProfile();
  }

  @override
  Future<void> saveBusinessProfile(BusinessProfileEntity profile) async {
    await sharedPreferences.setString(
      shared.PreferencesKeys.businessProfileInfo.name,
      profile.toJson(),
    );
  }
}

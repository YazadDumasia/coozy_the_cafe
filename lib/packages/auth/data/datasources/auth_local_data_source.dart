import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

abstract class AuthLocalDataSource {
  Future<void> saveLoginState(bool isLoggedIn);
  bool getLoginState();
  Future<void> saveUserRole(String role);
  String? getUserRole();

  Future<void> saveSuperUserFlag(bool isSuperUser);
  bool getSuperUserFlag();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> saveLoginState(bool isLoggedIn) async {
    await shared.LocalManager.instance.setBoolValue(
      key: shared.PreferencesKeys.isLoggedIn,
      value: isLoggedIn,
    );
  }

  @override
  bool getLoginState() {
    return shared.LocalManager.instance.getBoolValue(
      key: shared.PreferencesKeys.isLoggedIn,
    );
  }

  @override
  Future<void> saveUserRole(String role) async {
    await shared.LocalManager.instance.setLocaleKeys(
      key: shared.PreferencesKeys.userRole,
      value: role,
    );
  }

  @override
  String? getUserRole() {
    return shared.LocalManager.instance.getLocaleKeys(
      key: shared.PreferencesKeys.userRole,
    );
  }

  @override
  Future<void> saveSuperUserFlag(bool isSuperUser) async {
    await shared.LocalManager.instance.setBoolValue(
      key: shared.PreferencesKeys.isSuperUser,
      value: isSuperUser,
    );
  }

  @override
  bool getSuperUserFlag() {
    return shared.LocalManager.instance.getBoolValue(
      key: shared.PreferencesKeys.isSuperUser,
    );
  }

  @override
  Future<void> clear() async {
    await shared.LocalManager.instance.setBoolValue(
      key: shared.PreferencesKeys.isLoggedIn,
      value: false,
    );
    await shared.LocalManager.instance.setLocaleKeys(
      key: shared.PreferencesKeys.userRole,
      value: '',
    );
    await shared.LocalManager.instance.setBoolValue(
      key: shared.PreferencesKeys.businessOnboardingCompleted,
      value: false,
    );
    await shared.LocalManager.instance.setBoolValue(
      key: shared.PreferencesKeys.isSuperUser,
      value: false,
    );
  }
}

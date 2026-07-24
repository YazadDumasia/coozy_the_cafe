import '../../../core/coozy_core.dart' as core;
import '../usecases/get_current_user_ip_info_usecase.dart';
import '../usecases/get_ip_address_usecase.dart';

class AuthDeviceInfoService {
  final GetIpAddressUseCase getIpAddressUseCase;
  final GetCurrentUserIpInfoUseCase getCurrentUserIpInfoUseCase;

  AuthDeviceInfoService({
    required this.getIpAddressUseCase,
    required this.getCurrentUserIpInfoUseCase,
  });

  Future<String> getPlatform() => core.PlatformUtils.getCurrentPlatform();

  Future<String> getBuildMode() =>
      core.PlatformUtils.getCurrentPlatformBuildMode();

  Future<String?> getIpAddress() => getIpAddressUseCase();

  Future<dynamic> getIpInfo() => getCurrentUserIpInfoUseCase();

  Future<Map<String, dynamic>> getDeviceInfo() async {
    final results = await Future.wait([
      getPlatform(),
      getBuildMode(),
      getIpAddress().then((value) => value ?? 'Unknown'),
      getIpInfo(),
    ]);

    return {
      'platform': results[0],
      'buildMode': results[1],
      'ipAddress': results[2],
      'ipInfo': results[3],
    };
  }
}

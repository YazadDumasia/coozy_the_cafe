import '../../domain/repositories/ip_location_repository.dart';
import '../datasources/ip_location_remote_data_source.dart';

class IpLocationRepositoryImpl implements IpLocationRepository {
  final IpLocationRemoteDataSource remoteDataSource;

  IpLocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String?> getCountryIsoCode3FromIp() async {
    final String? ip = await getIpAddress();
    if (ip != null) {
      return await remoteDataSource.getCountryIso3CodeFromIpInfo(ip);
    }
    return null;
  }

  @override
  Future<dynamic> getCurrentUserIpInfo() async {
    final String? ip = await getIpAddress();
    if (ip != null) {
      return await remoteDataSource.getIpInfo(ip);
    }
    return null;
  }

  @override
  Future<String?> getIpAddress() async {
    String? ip = await remoteDataSource.getPublicIp4();
    ip ??= await remoteDataSource.getPublicIp6();
    return ip;
  }
}

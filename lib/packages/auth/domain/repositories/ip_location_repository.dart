abstract class IpLocationRepository {
  Future<String?> getCountryIsoCode3FromIp();
  Future<String?> getIpAddress();
  Future<dynamic> getCurrentUserIpInfo();
}

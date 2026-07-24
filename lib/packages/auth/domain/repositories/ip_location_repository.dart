abstract class IpLocationRepository {
  Future<String?> getCountryCodeFromIp();
  Future<String?> getIpAddress();
  Future<dynamic> getCurrentUserIpInfo();
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/coozy_core.dart' as core;

abstract class IpLocationRemoteDataSource {
  Future<String?> getPublicIp4();
  Future<String?> getPublicIp6();
  Future<String?> getCountryCodeFromIpInfo(String ipAddress);
  Future<dynamic> getIpInfo(String ipAddress);
}

class IpLocationRemoteDataSourceImpl implements IpLocationRemoteDataSource {
  final http.Client client;

  static const String _ipv4Url = 'https://api.ipify.org?format=json';
  static const String _ipv6Url = 'https://api64.ipify.org/?format=json';
  static const String _ipInfoBaseUrl = 'https://api.incolumitas.com/?q=';
  static const Duration _timeout = Duration(seconds: 5);

  IpLocationRemoteDataSourceImpl({required this.client});

  @override
  Future<String?> getPublicIp4() async {
    final data = await _performGet(_ipv4Url, 'IPv4');
    return data?['ip'] as String?;
  }

  @override
  Future<String?> getPublicIp6() async {
    final data = await _performGet(_ipv6Url, 'IPv6');
    return data?['ip'] as String?;
  }

  @override
  Future<dynamic> getIpInfo(String ipAddress) async {
    return await _performGet('$_ipInfoBaseUrl$ipAddress', 'IP Info');
  }

  @override
  Future<String?> getCountryCodeFromIpInfo(String ipAddress) async {
    final data = await getIpInfo(ipAddress);
    if (data != null && data['location'] != null) {
      final countryCode = data['location']['country_code'] as String?;
      return countryCode?.trim();
    }
    return null;
  }

  Future<dynamic> _performGet(String url, String label) async {
    try {
      final response = await client.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        core.PlatformUtils.debugLog(
          IpLocationRemoteDataSourceImpl,
          '$label Data: $data',
        );
        return data;
      } else {
        core.PlatformUtils.debugLog(
          IpLocationRemoteDataSourceImpl,
          'Failed to get $label. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        IpLocationRemoteDataSourceImpl,
        'Error during $label request: $e',
      );
    }
    return null;
  }
}

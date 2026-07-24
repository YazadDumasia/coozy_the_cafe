class AppConfig {
  static const String appName = 'Coozy The Cafe';

  static Map<String, String> httpGetHeader = <String, String>{
    'Access-Control-Allow-Origin': '*',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Map<String, String> httpImageGetHeader = <String, String>{
    'Accept': '*/*',
  };

  static Map<String, String> httpPostHeader = <String, String>{
    'Access-Control-Allow-Origin': '*',
    // "authToken": token,
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  static Map<String, String> httpPostHeaderForEncode = <String, String>{
    'Access-Control-Allow-Origin': '*',
    // "authToken": token,
    'Accept': 'application/json',
    'Content-type': 'application/x-www-form-urlencoded',
  };
}

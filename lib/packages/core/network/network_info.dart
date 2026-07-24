import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<InternetStatus> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection _connectionChecker;

  /// Creates a [NetworkInfoImpl].
  /// An [InternetConnection] instance can be injected for testing;
  /// if omitted, a default instance is created internally.
  NetworkInfoImpl([InternetConnection? connectionChecker])
    : _connectionChecker = connectionChecker ?? InternetConnection();

  @override
  Future<bool> get isConnected => _connectionChecker.hasInternetAccess;

  @override
  Stream<InternetStatus> get onStatusChange =>
      _connectionChecker.onStatusChange;
}

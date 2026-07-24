import '../repositories/ip_location_repository.dart';

class GetCurrentUserIpInfoUseCase {
  final IpLocationRepository repository;

  GetCurrentUserIpInfoUseCase(this.repository);

  Future<dynamic> call() {
    return repository.getCurrentUserIpInfo();
  }
}

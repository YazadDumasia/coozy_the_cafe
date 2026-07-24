import '../repositories/ip_location_repository.dart';

class GetIpAddressUseCase {
  final IpLocationRepository repository;

  GetIpAddressUseCase(this.repository);

  Future<String?> call() {
    return repository.getIpAddress();
  }
}

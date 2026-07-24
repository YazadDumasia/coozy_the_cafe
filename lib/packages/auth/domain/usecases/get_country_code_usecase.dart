import '../repositories/ip_location_repository.dart';

class GetCountryCodeUseCase {
  final IpLocationRepository repository;

  GetCountryCodeUseCase(this.repository);

  Future<String?> call() {
    return repository.getCountryCodeFromIp();
  }
}

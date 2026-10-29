import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/business_profile_entity.dart';
import '../repositories/business_profile_repository.dart';

class GetBusinessProfileUseCase {
  final BusinessProfileRepository repository;

  GetBusinessProfileUseCase({required this.repository});

  Future<Either<Failure, BusinessProfileEntity>> call() {
    return repository.getBusinessProfile();
  }
}

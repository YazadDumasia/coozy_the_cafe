import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/business_profile_entity.dart';
import '../repositories/business_profile_repository.dart';

class SaveBusinessProfileUseCase {
  final BusinessProfileRepository repository;

  SaveBusinessProfileUseCase({required this.repository});

  Future<Either<Failure, Unit>> call(BusinessProfileEntity profile) {
    return repository.saveBusinessProfile(profile);
  }
}

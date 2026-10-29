import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/business_profile_entity.dart';

abstract class BusinessProfileRepository {
  Future<Either<Failure, BusinessProfileEntity>> getBusinessProfile();
  Future<Either<Failure, Unit>> saveBusinessProfile(BusinessProfileEntity profile);
}

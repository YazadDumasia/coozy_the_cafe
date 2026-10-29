import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../../domain/entities/business_profile_entity.dart';
import '../../domain/repositories/business_profile_repository.dart';
import '../datasources/business_profile_local_data_source.dart';

class BusinessProfileRepositoryImpl implements BusinessProfileRepository {
  final BusinessProfileLocalDataSource localDataSource;

  BusinessProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, BusinessProfileEntity>> getBusinessProfile() async {
    try {
      final profile = await localDataSource.getBusinessProfile();
      return Right(profile);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveBusinessProfile(
    BusinessProfileEntity profile,
  ) async {
    try {
      await localDataSource.saveBusinessProfile(profile);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}

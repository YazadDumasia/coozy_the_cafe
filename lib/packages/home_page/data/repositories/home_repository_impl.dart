import '../../domain/entities/home_data.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HomeData> getHomeData() async {
    try {
      final message = await remoteDataSource.fetchHomeData();
      return HomeData(message: message);
    } catch (e) {
      // Handle exception or map to failure
      rethrow;
    }
  }
}

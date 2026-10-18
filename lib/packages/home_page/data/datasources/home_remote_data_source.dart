abstract class HomeRemoteDataSource {
  Future<String> fetchHomeData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<String> fetchHomeData() async {
    // Artificial latency for placeholder data
    await Future.delayed(const Duration(seconds: 1));
    return "Welcome to Coozy the Cafe!";
  }
}

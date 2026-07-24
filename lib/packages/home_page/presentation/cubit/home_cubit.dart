import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;

  HomeCubit({required this.getHomeDataUseCase}) : super(HomeInitial());

  Future<void> fetchHomeData() async {
    emit(HomeLoading());
    try {
      final data = await getHomeDataUseCase.call();
      emit(HomeLoaded(message: data.message));
    } catch (e) {
      emit(HomeError(errorMessage: 'Failed to fetch home data.'));
    }
  }
}

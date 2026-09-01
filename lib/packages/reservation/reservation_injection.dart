import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'data/datasources/reservation_local_data_source.dart';
import 'data/repositories/reservation_repository_impl.dart';
import 'domain/repositories/reservation_repository.dart';
import 'domain/usecases/reservation_usecases.dart';
import 'presentation/bloc/current_reservation_cubit.dart';
import 'presentation/bloc/upcoming_reservation_bloc.dart';
import 'presentation/bloc/reservation_action_cubit.dart';

import 'domain/usecases/convert_reservation_to_order_usecase.dart';

void registerReservationDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<ReservationLocalDataSource>(
    () => ReservationLocalDataSourceImpl(sl<CoozyDatabase>().reservationsDao),
  );

  // Repository
  sl.registerLazySingleton<ReservationRepository>(
    () => ReservationRepositoryImpl(sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetCurrentReservationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUpcomingReservationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUpcomingReservationsCountUseCase(sl()));
  sl.registerLazySingleton(() => SearchReservationsUseCase(sl()));
  sl.registerLazySingleton(() => CreateReservationUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReservationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReservationUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReservationStatusUseCase(sl()));
  sl.registerLazySingleton(() => ConvertReservationToOrderUseCase(sl()));

  // BLoC / Cubits
  sl.registerFactory(
    () => CurrentReservationCubit(getCurrentReservationsUseCase: sl()),
  );

  sl.registerFactory(
    () => UpcomingReservationBloc(
      getUpcomingReservationsUseCase: sl(),
      getUpcomingReservationsCountUseCase: sl(),
      searchReservationsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ReservationActionCubit(
      createReservationUseCase: sl(),
      updateReservationUseCase: sl(),
      deleteReservationUseCase: sl(),
      updateReservationStatusUseCase: sl(),
      convertReservationToOrderUseCase: sl(),
    ),
  );
}

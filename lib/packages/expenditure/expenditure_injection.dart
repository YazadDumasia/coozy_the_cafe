import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import 'data/datasources/expenditure_local_data_source.dart';
import 'data/repositories/expenditure_repository_impl.dart';
import 'domain/repositories/expenditure_repository.dart';
import 'domain/usecases/get_cash_flow_summary_usecase.dart';
import 'domain/usecases/get_expenditures_by_date_range_usecase.dart';
import 'domain/usecases/get_expenditure_categories_usecase.dart';
import 'domain/usecases/expenditure_mutation_usecases.dart';
import 'domain/usecases/get_expenditure_chart_data_usecase.dart';
import 'presentation/bloc/cash_flow_bloc.dart';

void registerExpenditureDependencies(GetIt sl) {
  // BLoC
  sl.registerFactory(
    () => CashFlowBloc(
      getCashFlowSummary: sl(),
      getExpendituresByDateRange: sl(),
      addExpenditure: sl(),
      deleteExpenditure: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCashFlowSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetExpendituresByDateRangeUseCase(sl()));
  sl.registerLazySingleton(() => GetExpenditureCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddExpenditureUseCase(sl()));
  sl.registerLazySingleton(() => DeleteExpenditureUseCase(sl()));
  sl.registerLazySingleton(() => AddCustomCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetExpenditureChartDataUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ExpenditureRepository>(
    () => ExpenditureRepositoryImpl(localDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<ExpenditureLocalDataSource>(
    () => ExpenditureLocalDataSourceImpl(sl<CoozyDatabase>().expenditureDao),
  );
}

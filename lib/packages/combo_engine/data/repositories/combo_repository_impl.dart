import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';

import '../../domain/entities/combo.dart';
import '../../domain/repositories/combo_repository.dart';
import '../datasources/combo_local_datasource.dart';

class ComboRepositoryImpl implements ComboRepository {
  final ComboLocalDataSource localDataSource;

  ComboRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Combo>>> getCombos({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  }) async {
    try {
      final combos = await localDataSource.getCombos(
        searchQuery: searchQuery,
        onlyActive: onlyActive,
        limit: limit,
        offset: offset,
      );
      return Right(combos);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Combo>>> watchCombos({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  }) {
    try {
      return localDataSource
          .watchCombos(
            searchQuery: searchQuery,
            onlyActive: onlyActive,
            limit: limit,
            offset: offset,
          )
          .map((combos) => Right<Failure, List<Combo>>(combos));
    } catch (e) {
      return Stream.value(Left(DatabaseFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Combo?>> getComboById(int id) async {
    try {
      final combo = await localDataSource.getComboById(id);
      return Right(combo);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createCombo(Combo combo) async {
    try {
      final id = await localDataSource.createCombo(combo);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCombo(Combo combo) async {
    try {
      final success = await localDataSource.updateCombo(combo);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCombo(int id) async {
    try {
      final success = await localDataSource.deleteCombo(id);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleComboStatus(int id, bool isActive) async {
    try {
      final success = await localDataSource.toggleComboStatus(id, isActive);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MenuItem>>> searchMenuItems({
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    try {
      final items = await localDataSource.searchMenuItems(
        searchQuery: searchQuery,
        limit: limit,
        offset: offset,
      );
      return Right(items);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getMenuItemsCount({String? searchQuery}) async {
    try {
      final count = await localDataSource.getMenuItemsCount(
        searchQuery: searchQuery,
      );
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateComboSortOrders(
    List<Combo> combos,
  ) async {
    try {
      await localDataSource.updateComboSortOrders(combos);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

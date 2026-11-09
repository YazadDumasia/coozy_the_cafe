import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';

import '../entities/combo.dart';

abstract class ComboRepository {
  Future<Either<Failure, List<Combo>>> getCombos({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  });

  Stream<Either<Failure, List<Combo>>> watchCombos({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, Combo?>> getComboById(int id);

  Future<Either<Failure, int>> createCombo(Combo combo);

  Future<Either<Failure, bool>> updateCombo(Combo combo);

  Future<Either<Failure, bool>> deleteCombo(int id);

  Future<Either<Failure, bool>> toggleComboStatus(int id, bool isActive);

  Future<Either<Failure, List<MenuItem>>> searchMenuItems({
    String? searchQuery,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, int>> getMenuItemsCount({String? searchQuery});
}

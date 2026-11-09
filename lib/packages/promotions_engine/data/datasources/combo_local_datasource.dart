import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart'
    hide MenuItem, MenuItemVariation;
import 'package:coozy_the_cafe/packages/database/src/database_dao/combos_dao.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item_variation.dart';

import '../../domain/entities/combo.dart';
import '../../domain/entities/combo_item.dart';

abstract class ComboLocalDataSource {
  Future<List<Combo>> getCombos({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  });

  Stream<List<Combo>> watchCombos({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  });

  Future<Combo?> getComboById(int id);

  Future<int> createCombo(Combo combo);

  Future<bool> updateCombo(Combo combo);

  Future<bool> deleteCombo(int id);

  Future<bool> toggleComboStatus(int id, bool isActive);

  Future<List<MenuItem>> searchMenuItems({
    String? searchQuery,
    int? limit,
    int? offset,
  });

  Future<int> getMenuItemsCount({String? searchQuery});
}

class ComboLocalDataSourceImpl implements ComboLocalDataSource {
  final CoozyDatabase database;

  ComboLocalDataSourceImpl({required this.database});

  @override
  Future<List<Combo>> getCombos({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  }) async {
    PlatformUtils.debugLog(
      ComboLocalDataSourceImpl,
      'getCombos: query="$searchQuery", onlyActive=$onlyActive, limit=$limit, offset=$offset',
    );
    final list = await database.combosDao.getCombos(
      searchQuery: searchQuery,
      onlyActive: onlyActive,
      limit: limit,
      offset: offset,
    );
    PlatformUtils.debugLog(
      ComboLocalDataSourceImpl,
      'getCombos returned ${list.length} rows',
    );
    return list.map(_mapComboWithItemsToEntity).toList();
  }

  @override
  Stream<List<Combo>> watchCombos({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  }) {
    PlatformUtils.debugLog(
      ComboLocalDataSourceImpl,
      'watchCombos stream initiated: query="$searchQuery", onlyActive=$onlyActive',
    );
    return database.combosDao
        .watchCombos(
          searchQuery: searchQuery,
          onlyActive: onlyActive,
          limit: limit,
          offset: offset,
        )
        .map((list) {
          PlatformUtils.debugLog(
            ComboLocalDataSourceImpl,
            'watchCombos stream emitted ${list.length} records',
          );
          return list.map(_mapComboWithItemsToEntity).toList();
        });
  }

  @override
  Future<Combo?> getComboById(int id) async {
    PlatformUtils.debugLog(ComboLocalDataSourceImpl, 'getComboById: id=$id');
    final comboWithItems = await database.combosDao.getComboById(id);
    if (comboWithItems == null) return null;
    return _mapComboWithItemsToEntity(comboWithItems);
  }

  @override
  Future<int> createCombo(Combo combo) async {
    PlatformUtils.debugLog(
      ComboLocalDataSourceImpl,
      'createCombo: name="${combo.name}", items=${combo.items.length}',
    );
    final comboCompanion = CombosTableCompanion(
      name: Value(combo.name),
      description: Value(combo.description),
      originalPrice: Value(combo.calculatedOriginalPrice),
      sellingPrice: Value(combo.sellingPrice),
      duration: Value(combo.duration),
      isActive: Value(combo.isActive),
      sortOrderIndex: Value(combo.sortOrderIndex),
      creationDate: Value(combo.creationDate),
      modificationDate: Value(combo.modificationDate),
    );

    final itemCompanions = combo.items.map((item) {
      return ComboItemsTableCompanion(
        menuItemId: Value(item.menuItemId),
        variationId: Value(item.variationId),
        quantity: Value(item.quantity),
      );
    }).toList();

    final id = await database.combosDao.createCombo(
      combo: comboCompanion,
      items: itemCompanions,
    );
    PlatformUtils.debugLog(
      ComboLocalDataSourceImpl,
      'createCombo finished with id=$id',
    );
    return id;
  }

  @override
  Future<bool> updateCombo(Combo combo) async {
    PlatformUtils.debugLog(
      ComboLocalDataSourceImpl,
      'updateCombo: id=${combo.id}, name="${combo.name}", items=${combo.items.length}',
    );
    if (combo.id == null) return false;

    final comboCompanion = CombosTableCompanion(
      name: Value(combo.name),
      description: Value(combo.description),
      originalPrice: Value(combo.calculatedOriginalPrice),
      sellingPrice: Value(combo.sellingPrice),
      duration: Value(combo.duration),
      isActive: Value(combo.isActive),
      sortOrderIndex: Value(combo.sortOrderIndex),
      modificationDate: Value(combo.modificationDate),
    );

    final itemCompanions = combo.items.map((item) {
      return ComboItemsTableCompanion(
        comboId: Value(combo.id!),
        menuItemId: Value(item.menuItemId),
        variationId: Value(item.variationId),
        quantity: Value(item.quantity),
      );
    }).toList();

    final result = await database.combosDao.updateCombo(
      id: combo.id!,
      combo: comboCompanion,
      items: itemCompanions,
    );
    PlatformUtils.debugLog(
      ComboLocalDataSourceImpl,
      'updateCombo result=$result',
    );
    return result;
  }

  @override
  Future<bool> deleteCombo(int id) async {
    PlatformUtils.debugLog(ComboLocalDataSourceImpl, 'deleteCombo: id=$id');
    final deleted = await database.combosDao.deleteCombo(id);
    PlatformUtils.debugLog(
      ComboLocalDataSourceImpl,
      'deleteCombo deleted=$deleted',
    );
    return deleted > 0;
  }

  @override
  Future<bool> toggleComboStatus(int id, bool isActive) async {
    PlatformUtils.debugLog(
      ComboLocalDataSourceImpl,
      'toggleComboStatus: id=$id, isActive=$isActive',
    );
    final result = await database.combosDao.toggleComboStatus(id, isActive);
    PlatformUtils.debugLog(
      ComboLocalDataSourceImpl,
      'toggleComboStatus result=$result',
    );
    return result;
  }

  @override
  Future<List<MenuItem>> searchMenuItems({
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    final query = database.select(database.menuItemsTable);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where((t) => t.name.lower().like(term));
    }

    query.orderBy([
      (t) => OrderingTerm(expression: t.sortOrderIndex, mode: OrderingMode.asc),
      (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
    ]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    final rows = await query.get();
    final result = <MenuItem>[];

    for (final row in rows) {
      final variations = await (database.select(
        database.menuItemVariationsTable,
      )..where((t) => t.menuItemId.equals(row.id))).get();

      result.add(
        MenuItem(
          id: row.id,
          hashId: row.hashId,
          name: row.name,
          description: row.description,
          foodType: row.foodType,
          creationDate: row.creationDate,
          modificationDate: row.modificationDate,
          duration: row.duration,
          categoryId: row.categoryId,
          subcategoryId: row.subcategoryId,
          isTodayAvailable: row.isTodayAvailable,
          isSimpleVariation: row.isSimpleVariation,
          costPrice: row.costPrice,
          sellingPrice: row.sellingPrice,
          stockQuantity: row.stockQuantity,
          quantity: row.quantity,
          purchaseUnit: row.purchaseUnit,
          sortOrderIndex: row.sortOrderIndex,
          variations: variations.map((v) {
            return MenuItemVariation(
              id: v.id,
              hashId: v.hashId,
              menuItemId: v.menuItemId,
              name: v.name,
              costPrice: v.costPrice,
              sellingPrice: v.sellingPrice,
              stockQuantity: v.stockQuantity,
              sortOrderIndex: v.sortOrderIndex,
              duration: v.duration,
            );
          }).toList(),
        ),
      );
    }

    return result;
  }

  @override
  Future<int> getMenuItemsCount({String? searchQuery}) async {
    final countExp = database.menuItemsTable.id.count();
    final query = database.selectOnly(database.menuItemsTable)
      ..addColumns([countExp]);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where(database.menuItemsTable.name.lower().like(term));
    }

    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Combo _mapComboWithItemsToEntity(ComboWithItems cwi) {
    return Combo(
      id: cwi.combo.id,
      hashId: cwi.combo.hashId,
      name: cwi.combo.name,
      description: cwi.combo.description,
      originalPrice: cwi.combo.originalPrice,
      sellingPrice: cwi.combo.sellingPrice,
      duration: cwi.combo.duration,
      isActive: cwi.combo.isActive,
      sortOrderIndex: cwi.combo.sortOrderIndex,
      creationDate: cwi.combo.creationDate,
      modificationDate: cwi.combo.modificationDate,
      items: cwi.items.map((itemWithDetail) {
        final d = itemWithDetail.comboItem;
        final m = itemWithDetail.menuItem;
        final v = itemWithDetail.variation;

        return ComboItem(
          id: d.id,
          hashId: d.hashId,
          comboId: d.comboId,
          menuItemId: d.menuItemId,
          variationId: d.variationId,
          quantity: d.quantity,
          menuItem: MenuItem(
            id: m.id,
            hashId: m.hashId,
            name: m.name,
            description: m.description,
            foodType: m.foodType,
            duration: m.duration,
            costPrice: m.costPrice,
            sellingPrice: m.sellingPrice,
            isTodayAvailable: m.isTodayAvailable,
          ),
          variation: v != null
              ? MenuItemVariation(
                  id: v.id,
                  hashId: v.hashId,
                  menuItemId: v.menuItemId,
                  name: v.name,
                  sellingPrice: v.sellingPrice,
                  costPrice: v.costPrice,
                  duration: v.duration,
                )
              : null,
        );
      }).toList(),
    );
  }
}

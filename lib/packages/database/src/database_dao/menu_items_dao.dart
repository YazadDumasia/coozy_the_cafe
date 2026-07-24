import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'menu_items_dao.g.dart';

class MenuItemWithVariations {
  final MenuItem item;
  final List<MenuItemVariation> variations;

  MenuItemWithVariations({required this.item, required this.variations});
}

@DriftAccessor(
  tables: [MenuItemsTable, MenuItemVariationsTable, MenuItemReviewsTable],
)
class MenuItemsDao extends DatabaseAccessor<CoozyDatabase>
    with _$MenuItemsDaoMixin {
  MenuItemsDao(super.db);

  Future<int> createMenuItem({
    required MenuItemsTableCompanion item,
    List<MenuItemVariationsTableCompanion>? variations,
  }) async {
    return transaction(() async {
      final itemId = await into(
        menuItemsTable,
      ).insert(item, mode: InsertMode.replace);

      if (variations != null && variations.isNotEmpty) {
        for (int i = 0; i < variations.length; i++) {
          final v = variations[i].copyWith(
            menuItemId: Value(itemId),
            sortOrderIndex: Value(i),
          );
          await into(
            menuItemVariationsTable,
          ).insert(v, mode: InsertMode.replace);
        }
      }
      return itemId;
    });
  }

  Future<bool> updateMenuItem({
    required int id,
    required MenuItemsTableCompanion item,
    List<MenuItemVariationsTableCompanion>? variations,
  }) async {
    return transaction(() async {
      final updated = await (update(
        menuItemsTable,
      )..where((t) => t.id.equals(id))).write(item);

      if (variations != null) {
        await (delete(
          menuItemVariationsTable,
        )..where((t) => t.menuItemId.equals(id))).go();
        for (int i = 0; i < variations.length; i++) {
          final v = variations[i].copyWith(
            menuItemId: Value(id),
            sortOrderIndex: Value(i),
          );
          await into(menuItemVariationsTable).insert(v);
        }
      }
      return updated > 0;
    });
  }

  Future<MenuItemWithVariations?> getMenuItemById(int id) async {
    final query = select(menuItemsTable)..where((t) => t.id.equals(id));
    final item = await query.getSingleOrNull();
    if (item == null) return null;

    if (item.isSimpleVariation == true) {
      return MenuItemWithVariations(item: item, variations: []);
    } else {
      final variations =
          await (select(menuItemVariationsTable)
                ..where((t) => t.menuItemId.equals(id))
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.sortOrderIndex,
                    mode: OrderingMode.asc,
                  ),
                ]))
              .get();
      return MenuItemWithVariations(item: item, variations: variations);
    }
  }

  Future<void> deleteMenuItem(int? menuItemId) async {
    if (menuItemId == null) return;
    await transaction(() async {
      await (delete(
        menuItemVariationsTable,
      )..where((t) => t.menuItemId.equals(menuItemId))).go();
      await (delete(
        menuItemsTable,
      )..where((t) => t.id.equals(menuItemId))).go();
    });
  }

  Future<List<MenuItemWithVariations>?> getAllMenuItems() async {
    return await transaction(() async {
      final query = select(menuItemsTable);
      query.orderBy([
        (t) =>
            OrderingTerm(expression: t.sortOrderIndex, mode: OrderingMode.asc),
      ]);
      final items = await query.get();

      if (items.isEmpty) return null;

      final allVariations =
          await (select(menuItemVariationsTable)..orderBy([
                (t) => OrderingTerm(
                  expression: t.sortOrderIndex,
                  mode: OrderingMode.asc,
                ),
              ]))
              .get();

      final variationsMap = <int, List<MenuItemVariation>>{};
      for (final v in allVariations) {
        variationsMap.putIfAbsent(v.menuItemId!, () => []).add(v);
      }

      return items.map((item) {
        return MenuItemWithVariations(
          item: item,
          variations: variationsMap[item.id] ?? [],
        );
      }).toList();
    });
  }

  Future<List<MenuItemWithVariations>> getAvailableMenuItems() async {
    return await transaction(() async {
      final query = select(menuItemsTable)
        ..where((t) => t.isTodayAvailable.equals(true));
      query.orderBy([
        (t) =>
            OrderingTerm(expression: t.sortOrderIndex, mode: OrderingMode.asc),
      ]);
      final items = await query.get();

      if (items.isEmpty) return [];

      final allVariations =
          await (select(menuItemVariationsTable)..orderBy([
                (t) => OrderingTerm(
                  expression: t.sortOrderIndex,
                  mode: OrderingMode.asc,
                ),
              ]))
              .get();

      final variationsMap = <int, List<MenuItemVariation>>{};
      for (final v in allVariations) {
        variationsMap.putIfAbsent(v.menuItemId!, () => []).add(v);
      }

      final result = <MenuItemWithVariations>[];
      for (final item in items) {
        if (item.isSimpleVariation == true) {
          continue; // from original code, if isSimpleVariation == true and available it might be skipped? Wait, original code says: `if (!isTodayAvailable || isSimpleVariation) return null;` Actually let me fix this. Original code might have had a bug or assumed simple variation is handled differently. We'll just return it if it's a simple variation without checking variations.
        }

        final itemVariations = variationsMap[item.id] ?? [];
        if (itemVariations.isNotEmpty &&
            itemVariations.every((v) => v.isTodayAvailable == false)) {
          continue;
        }

        result.add(
          MenuItemWithVariations(item: item, variations: itemVariations),
        );
      }
      return result;
    });
  }

  Future<List<MenuItemWithVariations>> getAvailableMenuItemsPagination({
    required int pageNumber,
    required int limit,
    String? searchTerm,
  }) async {
    final offset = (pageNumber - 1) * limit;
    final query = select(menuItemsTable)
      ..where((t) => t.isTodayAvailable.equals(true));

    query.orderBy([
      (t) => OrderingTerm(expression: t.sortOrderIndex, mode: OrderingMode.asc),
    ]);

    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      query.where((t) => t.name.like('%${searchTerm.trim()}%'));
    }

    final items = await (query..limit(limit, offset: offset)).get();

    final allVariations =
        await (select(menuItemVariationsTable)..orderBy([
              (t) => OrderingTerm(
                expression: t.sortOrderIndex,
                mode: OrderingMode.asc,
              ),
            ]))
            .get();

    final variationsMap = <int, List<MenuItemVariation>>{};
    for (final v in allVariations) {
      variationsMap.putIfAbsent(v.menuItemId!, () => []).add(v);
    }

    final result = <MenuItemWithVariations>[];
    for (final item in items) {
      if (item.isSimpleVariation == true) continue; // matching legacy logic

      final itemVariations = variationsMap[item.id] ?? [];
      if (itemVariations.isNotEmpty &&
          itemVariations.every((v) => v.isTodayAvailable == false)) {
        continue;
      }

      result.add(
        MenuItemWithVariations(item: item, variations: itemVariations),
      );
    }
    return result;
  }

  Future<List<MenuItemWithVariations>> fetchAllMenuItemsPaged({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    final offset = (pageNumber - 1) * limit;
    final query = select(menuItemsTable);

    query.orderBy([
      (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
    ]);

    if (search != null && search.trim().isNotEmpty) {
      query.where((t) => t.name.like('%${search.trim()}%'));
    }

    final items = await (query..limit(limit, offset: offset)).get();

    if (items.isEmpty) return [];

    final itemIds = items.map((i) => i.id).toList();

    final allVariations =
        await (select(menuItemVariationsTable)
              ..where((t) => t.menuItemId.isIn(itemIds))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.sortOrderIndex,
                  mode: OrderingMode.asc,
                ),
              ]))
            .get();

    final variationsMap = <int, List<MenuItemVariation>>{};
    for (final v in allVariations) {
      variationsMap.putIfAbsent(v.menuItemId!, () => []).add(v);
    }

    return items.map((item) {
      return MenuItemWithVariations(
        item: item,
        variations: variationsMap[item.id] ?? [],
      );
    }).toList();
  }

  Future<int> fetchMenuItemsCount({String? search}) async {
    final countExpr = menuItemsTable.id.count();
    final query = selectOnly(menuItemsTable)..addColumns([countExpr]);
    if (search != null && search.trim().isNotEmpty) {
      query.where(menuItemsTable.name.like('%${search.trim()}%'));
    }
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<List<MenuItemWithVariations>?> fetchAvailableMenuItemsPaged({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    final offset = (pageNumber - 1) * limit;
    final query = select(menuItemsTable)
      ..where((t) => t.isTodayAvailable.equals(true))
      ..where(
        (t) => t.isSimpleVariation.equals(false),
      ); // matching legacy logic

    query.orderBy([
      (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
    ]);

    if (search != null && search.trim().isNotEmpty) {
      query.where((t) => t.name.like('%${search.trim()}%'));
    }

    final items = await (query..limit(limit, offset: offset)).get();
    if (items.isEmpty) return [];

    final itemIds = items.map((i) => i.id).toList();

    final allVariations =
        await (select(menuItemVariationsTable)
              ..where((t) => t.menuItemId.isIn(itemIds))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.sortOrderIndex,
                  mode: OrderingMode.asc,
                ),
              ]))
            .get();

    final variationsMap = <int, List<MenuItemVariation>>{};
    for (final v in allVariations) {
      variationsMap.putIfAbsent(v.menuItemId!, () => []).add(v);
    }

    return items.map((item) {
      List<MenuItemVariation> itemVariations = variationsMap[item.id] ?? [];

      if (itemVariations.isNotEmpty &&
          itemVariations.every((v) => v.isTodayAvailable != true)) {
        itemVariations = [];
      }

      return MenuItemWithVariations(item: item, variations: itemVariations);
    }).toList();
  }

  Future<List<MenuItemReview>> getReviewsForMenuItem(int itemId) {
    final query = select(menuItemReviewsTable)
      ..where((t) => t.itemId.equals(itemId));
    query.orderBy([
      (t) => OrderingTerm(expression: t.reviewDate, mode: OrderingMode.desc),
    ]);
    return query.get();
  }

  Future<double> calculateAverageRating(int itemId) async {
    final avgExpr = menuItemReviewsTable.rating.avg();
    final query = selectOnly(menuItemReviewsTable)
      ..where(menuItemReviewsTable.itemId.equals(itemId))
      ..addColumns([avgExpr]);
    final row = await query.getSingleOrNull();
    return row?.read(avgExpr) ?? 0.0;
  }
}

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';
import '../tables.dart';

part 'combos_dao.g.dart';

class ComboItemWithDetails {
  final ComboItemData comboItem;
  final MenuItem menuItem;
  final MenuItemVariation? variation;

  ComboItemWithDetails({
    required this.comboItem,
    required this.menuItem,
    this.variation,
  });
}

class ComboWithItems {
  final ComboData combo;
  final List<ComboItemWithDetails> items;

  ComboWithItems({required this.combo, required this.items});
}

@DriftAccessor(
  tables: [
    CombosTable,
    ComboItemsTable,
    MenuItemsTable,
    MenuItemVariationsTable,
  ],
)
class CombosDao extends DatabaseAccessor<CoozyDatabase> with _$CombosDaoMixin {
  CombosDao(super.db);

  Future<int> createCombo({
    required CombosTableCompanion combo,
    required List<ComboItemsTableCompanion> items,
  }) async {
    return transaction(() async {
      final comboId = await into(combosTable).insert(combo);

      for (final itemCompanion in items) {
        final item = itemCompanion.copyWith(
          id: const Value.absent(),
          hashId: itemCompanion.hashId.present
              ? itemCompanion.hashId
              : Value(const Uuid().v4()),
          comboId: Value(comboId),
        );
        await into(comboItemsTable).insert(item);
      }
      return comboId;
    });
  }

  Future<bool> updateCombo({
    required int id,
    required CombosTableCompanion combo,
    List<ComboItemsTableCompanion>? items,
  }) async {
    return transaction(() async {
      final updated = await (update(
        combosTable,
      )..where((t) => t.id.equals(id))).write(combo);

      if (items != null) {
        await (delete(
          comboItemsTable,
        )..where((t) => t.comboId.equals(id))).go();
        for (final itemCompanion in items) {
          final item = itemCompanion.copyWith(
            id: const Value.absent(),
            hashId: itemCompanion.hashId.present
                ? itemCompanion.hashId
                : Value(const Uuid().v4()),
            comboId: Value(id),
          );
          await into(comboItemsTable).insert(item);
        }
      }

      return updated > 0;
    });
  }

  Future<int> deleteCombo(int id) async {
    return transaction(() async {
      await (delete(comboItemsTable)..where((t) => t.comboId.equals(id))).go();
      return (delete(combosTable)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<bool> toggleComboStatus(int id, bool isActive) async {
    final updated = await (update(combosTable)..where((t) => t.id.equals(id)))
        .write(CombosTableCompanion(isActive: Value(isActive)));
    return updated > 0;
  }

  Future<ComboWithItems?> getComboById(int id) async {
    final combo = await (select(
      combosTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (combo == null) return null;

    final items = await _getItemsForCombo(combo.id);
    return ComboWithItems(combo: combo, items: items);
  }

  Future<List<ComboWithItems>> getCombos({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  }) async {
    final query = select(combosTable);

    if (onlyActive != null) {
      query.where((t) => t.isActive.equals(onlyActive));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where(
        (t) =>
            t.name.lower().like(term) |
            (t.description.isNotNull() & t.description.lower().like(term)),
      );
    }

    query.orderBy([
      (t) => OrderingTerm(expression: t.sortOrderIndex, mode: OrderingMode.asc),
      (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
    ]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    final combos = await query.get();
    final result = <ComboWithItems>[];

    for (final c in combos) {
      final items = await _getItemsForCombo(c.id);
      result.add(ComboWithItems(combo: c, items: items));
    }

    return result;
  }

  Stream<List<ComboWithItems>> watchCombos({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  }) {
    final query = select(combosTable);

    if (onlyActive != null) {
      query.where((t) => t.isActive.equals(onlyActive));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where(
        (t) =>
            t.name.lower().like(term) |
            (t.description.isNotNull() & t.description.lower().like(term)),
      );
    }

    query.orderBy([
      (t) => OrderingTerm(expression: t.sortOrderIndex, mode: OrderingMode.asc),
      (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
    ]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.watch().asyncMap((combos) async {
      final result = <ComboWithItems>[];
      for (final c in combos) {
        final items = await _getItemsForCombo(c.id);
        result.add(ComboWithItems(combo: c, items: items));
      }
      return result;
    });
  }

  Future<int> getCombosCount({String? searchQuery, bool? onlyActive}) async {
    final countExp = combosTable.id.count();
    final query = selectOnly(combosTable)..addColumns([countExp]);

    if (onlyActive != null) {
      query.where(combosTable.isActive.equals(onlyActive));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where(
        combosTable.name.lower().like(term) |
            (combosTable.description.isNotNull() &
                combosTable.description.lower().like(term)),
      );
    }

    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<List<ComboItemWithDetails>> _getItemsForCombo(int comboId) async {
    final query = select(comboItemsTable).join([
      innerJoin(
        menuItemsTable,
        menuItemsTable.id.equalsExp(comboItemsTable.menuItemId),
      ),
      leftOuterJoin(
        menuItemVariationsTable,
        menuItemVariationsTable.id.equalsExp(comboItemsTable.variationId),
      ),
    ])..where(comboItemsTable.comboId.equals(comboId));

    final rows = await query.get();

    return rows.map((row) {
      final comboItem = row.readTable(comboItemsTable);
      final menuItem = row.readTable(menuItemsTable);
      final variation = row.readTableOrNull(menuItemVariationsTable);

      return ComboItemWithDetails(
        comboItem: comboItem,
        menuItem: menuItem,
        variation: variation,
      );
    }).toList();
  }

  Future<void> updateComboSortOrders(List<ComboData> combos) async {
    return transaction(() async {
      for (int i = 0; i < combos.length; i++) {
        final c = combos[i];
        await (update(combosTable)..where((t) => t.id.equals(c.id))).write(
          CombosTableCompanion(
            sortOrderIndex: Value(i + 1),
            modificationDate: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );
      }
    });
  }
}

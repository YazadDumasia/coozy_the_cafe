import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../../domain/entities/reservation_entity.dart';

abstract class ReservationLocalDataSource {
  Future<List<ReservationEntity>> getCurrentReservations();

  Future<List<ReservationEntity>> getUpcomingReservations({
    required int limit,
    required int pageNo,
  });

  Future<int> getUpcomingReservationsCount();

  Future<List<ReservationEntity>> searchReservations({
    required String query,
    required int limit,
    required int pageNo,
  });

  Future<ReservationEntity?> getReservationById(int id);

  Future<int> createReservation(ReservationEntity reservation);

  Future<bool> updateReservation(ReservationEntity reservation);

  Future<bool> updateReservationStatus({required int id, required int status});

  Future<int> deleteReservation(int id);

  Future<int> convertReservationToOrder(ReservationEntity reservation);
}

class ReservationLocalDataSourceImpl implements ReservationLocalDataSource {
  final ReservationsDao reservationsDao;

  ReservationLocalDataSourceImpl(this.reservationsDao);

  ReservationEntity _mapToEntity(Reservation data) {
    List<PreOrderedMenuItemEntity> items = [];
    String? cleanNotes = data.notes;

    if (data.notes != null && data.notes!.contains('PRE_ORDERED_ITEMS:')) {
      final parts = data.notes!.split('PRE_ORDERED_ITEMS:');
      cleanNotes = parts[0].trim();
      if (parts.length > 1) {
        try {
          final List decoded = jsonDecode(parts[1].trim());
          items = decoded
              .map((e) => PreOrderedMenuItemEntity.fromJson(e))
              .toList();
        } catch (_) {}
      }
    }

    return ReservationEntity(
      id: data.id,
      hashId: data.hashId,
      customerName: data.customerName,
      phoneNumber: data.phoneNumber,
      isoCode: data.isoCode,
      customerId: data.customerId,
      tableId: data.tableId,
      tableReservedName: data.tableReservedName,
      reservationDateTime: data.reservationDateTime,
      numberOfPeople: data.numberOfPeople,
      status: data.status,
      occasion: data.occasion,
      notes: cleanNotes,
      preOrderedItems: items,
      creationDate: data.creationDate,
      modificationDate: data.modificationDate,
    );
  }

  ReservationsTableCompanion _mapToCompanion(ReservationEntity entity) {
    String? combinedNotes = entity.notes;
    if (entity.preOrderedItems.isNotEmpty) {
      final jsonStr = jsonEncode(
        entity.preOrderedItems.map((e) => e.toJson()).toList(),
      );
      combinedNotes = (entity.notes != null && entity.notes!.isNotEmpty)
          ? '${entity.notes}\nPRE_ORDERED_ITEMS:$jsonStr'
          : 'PRE_ORDERED_ITEMS:$jsonStr';
    }

    return ReservationsTableCompanion(
      customerName: Value(entity.customerName),
      phoneNumber: Value(entity.phoneNumber),
      isoCode: Value(entity.isoCode),
      customerId: Value(entity.customerId),
      tableId: Value(entity.tableId),
      tableReservedName: Value(entity.tableReservedName),
      reservationDateTime: Value(entity.reservationDateTime),
      numberOfPeople: Value(entity.numberOfPeople),
      status: Value(entity.status ?? 0),
      occasion: Value(entity.occasion),
      notes: Value(combinedNotes),
      creationDate: Value(
        entity.creationDate ?? DateTime.now().toIso8601String(),
      ),
      modificationDate: Value(DateTime.now().toIso8601String()),
    );
  }

  @override
  Future<List<ReservationEntity>> getCurrentReservations() async {
    final list = await reservationsDao.getCurrentReservations();
    return list.map(_mapToEntity).toList();
  }

  @override
  Future<List<ReservationEntity>> getUpcomingReservations({
    required int limit,
    required int pageNo,
  }) async {
    final list = await reservationsDao.getUpcomingReservations(
      limit: limit,
      pageNo: pageNo,
    );
    return list.map(_mapToEntity).toList();
  }

  @override
  Future<int> getUpcomingReservationsCount() {
    return reservationsDao.getUpcomingReservationsCount();
  }

  @override
  Future<List<ReservationEntity>> searchReservations({
    required String query,
    required int limit,
    required int pageNo,
  }) async {
    final list = await reservationsDao.searchReservations(
      query,
      limit: limit,
      pageNo: pageNo,
    );
    return list.map(_mapToEntity).toList();
  }

  @override
  Future<ReservationEntity?> getReservationById(int id) async {
    final item = await reservationsDao.getReservationById(id);
    return item != null ? _mapToEntity(item) : null;
  }

  @override
  Future<int> createReservation(ReservationEntity reservation) {
    return reservationsDao.createReservation(_mapToCompanion(reservation));
  }

  @override
  Future<bool> updateReservation(ReservationEntity reservation) {
    if (reservation.id == null) return Future.value(false);
    return reservationsDao.updateReservation(
      reservation.id!,
      _mapToCompanion(reservation),
    );
  }

  @override
  Future<bool> updateReservationStatus({required int id, required int status}) {
    return reservationsDao.updateReservationStatus(id, status);
  }

  @override
  Future<int> deleteReservation(int id) {
    return reservationsDao.deleteReservation(id);
  }

  @override
  Future<int> convertReservationToOrder(ReservationEntity reservation) async {
    if (reservation.id == null) return -1;
    final db = reservationsDao.attachedDatabase;
    final existingOrder =
        await db.ordersDao.getOrderByReservationId(reservation.id!);

    int orderId = -1;
    final nowIso = DateTime.now().toUtc().toIso8601String();

    if (existingOrder != null) {
      await db.ordersDao.handleReservationArrival(
        reservationId: reservation.id!,
        tableInfoId: reservation.tableId ?? 1,
        tableNameText: reservation.tableReservedName,
      );
      orderId = existingOrder.id;
    } else {
      final orderCompanion = OrdersTableCompanion.insert(
        reservationId: Value(reservation.id),
        tableInfoId: Value(reservation.tableId ?? 1),
        customerId: Value(reservation.customerId),
        customerName: Value(reservation.customerName),
        phoneNumber: Value(reservation.phoneNumber),
        isoCode: Value(reservation.isoCode),
        tableNameText: Value(reservation.tableReservedName),
        orderType: const Value('Dine-In'),
        status: const Value('inProgress'),
        creationDate: Value(nowIso),
        modificationDate: Value(nowIso),
      );

      final itemsCompanions = reservation.preOrderedItems.map((item) {
        return OrderItemsTableCompanion.insert(
          itemId: Value(item.itemId),
          menuItemId: Value(item.itemId),
          quantity: Value(item.quantity),
          sellingPrice: Value(item.price),
          isMenuItem: const Value(true),
          status: const Value('inProgress'),
          creationDate: Value(nowIso),
        );
      }).toList();

      orderId = await db.ordersDao.createNewOrder(
        order: orderCompanion,
        orderItems: itemsCompanions,
      );
    }

    // Update reservation status to 2 (Completed/Seated)
    await reservationsDao.updateReservationStatus(reservation.id!, 2);
    return orderId;
  }
}

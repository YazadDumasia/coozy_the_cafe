import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'reservations_dao.g.dart';

@DriftAccessor(tables: [ReservationsTable])
class ReservationsDao extends DatabaseAccessor<CoozyDatabase>
    with _$ReservationsDaoMixin {
  ReservationsDao(super.db);

  Future<int> createReservation(ReservationsTableCompanion reservation) =>
      into(reservationsTable).insert(reservation);

  Future<Reservation?> getReservationById(int id) {
    final query = select(reservationsTable)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<List<Reservation>> getAllReservations() {
    final query = select(reservationsTable);
    return (query..orderBy([
          (t) => OrderingTerm(
            expression: t.reservationDateTime,
            mode: OrderingMode.desc,
          ),
        ]))
        .get();
  }

  Future<List<Reservation>> getReservationsPaginated({
    required int limit,
    required int pageNo,
  }) {
    final offset = (pageNo - 1) * limit;
    final query = select(reservationsTable);
    return (query
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.reservationDateTime,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<Reservation>> searchReservations(
    String queryStr, {
    required int limit,
    required int pageNo,
  }) {
    final offset = (pageNo - 1) * limit;
    final query = select(reservationsTable)
      ..where(
        (t) =>
            t.customerName.like('%$queryStr%') |
            t.phoneNumber.like('%$queryStr%') |
            t.isoCode.like('%$queryStr%'),
      );
    return (query
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.reservationDateTime,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<Reservation>> getReservationsByDate(String dateIso) async {
    String sql =
        'SELECT * FROM reservations WHERE DATE(reservation_date_time) = DATE(?)';
    List<Variable> vars = [Variable.withString(dateIso)];
    sql += ' ORDER BY reservation_date_time ASC';

    final rows = await customSelect(sql, variables: vars).get();
    return rows.map((r) => reservationsTable.map(r.data)).toList();
  }

  Future<List<Reservation>> getReservationsByStatus(int status) {
    final query = select(reservationsTable)
      ..where((t) => t.status.equals(status));
    return (query..orderBy([
          (t) => OrderingTerm(
            expression: t.reservationDateTime,
            mode: OrderingMode.desc,
          ),
        ]))
        .get();
  }

  Future<bool> updateReservation(
    int id,
    ReservationsTableCompanion reservation,
  ) => (update(
    reservationsTable,
  )..where((t) => t.id.equals(id))).write(reservation).then((rows) => rows > 0);

  Future<bool> updateReservationStatus(int id, int status) =>
      (update(reservationsTable)..where((t) => t.id.equals(id)))
          .write(
            ReservationsTableCompanion(
              status: Value(status),
              modificationDate: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          )
          .then((rows) => rows > 0);

  Future<int> deleteReservation(int id) =>
      (delete(reservationsTable)..where((t) => t.id.equals(id))).go();
}

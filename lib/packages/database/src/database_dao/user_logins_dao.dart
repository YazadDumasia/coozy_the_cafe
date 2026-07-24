import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'user_logins_dao.g.dart';

@DriftAccessor(
  tables: [RolesTable, UserLoginsTable, PermissionsTable, RolePermissionsTable],
)
class UserLoginsDao extends DatabaseAccessor<CoozyDatabase>
    with _$UserLoginsDaoMixin {
  UserLoginsDao(super.db);

  // ---- ROLES ----
  Future<int> createRole(RolesTableCompanion role) =>
      into(rolesTable).insertOnConflictUpdate(role);

  Future<List<UserRole>> getAllRoles() => select(rolesTable).get();

  Future<UserRole?> getRoleById(int id) =>
      (select(rolesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<bool> updateRole(int id, RolesTableCompanion role) => (update(
    rolesTable,
  )..where((t) => t.id.equals(id))).write(role).then((rows) => rows > 0);

  Future<int> deleteRole(int id) =>
      (delete(rolesTable)..where((t) => t.id.equals(id))).go();

  // ---- USER LOGINS ----
  Future<int> createUserLogin(UserLoginsTableCompanion user) =>
      into(userLoginsTable).insert(user);

  Future<UserLogin?> getUserById(int id) => (select(
    userLoginsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<UserLogin?> getUserByUsernameOrEmail(String usernameOrEmail) =>
      (select(userLoginsTable)..where(
            (t) =>
                t.username.equals(usernameOrEmail) |
                t.email.equals(usernameOrEmail),
          ))
          .getSingleOrNull();

  Future<bool> updateUser(int id, UserLoginsTableCompanion user) => (update(
    userLoginsTable,
  )..where((t) => t.id.equals(id))).write(user).then((rows) => rows > 0);

  Future<bool> updatePassword(int id, String passwordHash) =>
      (update(userLoginsTable)..where((t) => t.id.equals(id)))
          .write(
            UserLoginsTableCompanion(
              passwordHash: Value(passwordHash),
              updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          )
          .then((rows) => rows > 0);

  Future<int> deleteUser(int id) =>
      (delete(userLoginsTable)..where((t) => t.id.equals(id))).go();

  Future<List<UserLogin>> getUsersPaged({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) {
    final offset = (pageNumber - 1) * limit;
    final query = select(userLoginsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.username, mode: OrderingMode.asc),
      ]);
    if (search != null && search.isNotEmpty) {
      query.where(
        (t) =>
            t.firstName.like('%$search%') |
            t.lastName.like('%$search%') |
            t.username.like('%$search%') |
            t.phoneNumber.like('%$search%') |
            t.isoCode.like('%$search%'),
      );
    }
    return (query..limit(limit, offset: offset)).get();
  }

  Future<int> getUsersCount({String? search}) async {
    final countExpr = userLoginsTable.id.count();
    final query = selectOnly(userLoginsTable)..addColumns([countExpr]);
    if (search != null && search.isNotEmpty) {
      query.where(
        userLoginsTable.firstName.like('%$search%') |
            userLoginsTable.lastName.like('%$search%') |
            userLoginsTable.username.like('%$search%') |
            userLoginsTable.phoneNumber.like('%$search%') |
            userLoginsTable.isoCode.like('%$search%'),
      );
    }
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  // ---- PERMISSIONS ----
  Future<int> createPermission(PermissionsTableCompanion permission) =>
      into(permissionsTable).insertOnConflictUpdate(permission);

  Future<List<UserPermission>> getAllPermissions() =>
      select(permissionsTable).get();

  Future<int> assignPermissionToRole(int roleId, int permissionId) =>
      into(rolePermissionsTable).insert(
        RolePermissionsTableCompanion(
          roleId: Value(roleId),
          permissionId: Value(permissionId),
        ),
      );

  Future<int> revokePermissionFromRole(int roleId, int permissionId) =>
      (delete(rolePermissionsTable)..where(
            (t) =>
                t.roleId.equals(roleId) & t.permissionId.equals(permissionId),
          ))
          .go();

  Future<List<UserPermission>> getPermissionsForRole(int roleId) async {
    final query = select(permissionsTable).join([
      innerJoin(
        rolePermissionsTable,
        rolePermissionsTable.permissionId.equalsExp(permissionsTable.id),
      ),
    ])..where(rolePermissionsTable.roleId.equals(roleId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(permissionsTable)).toList();
  }

  Future<List<UserPermission>> getPermissionsForUser(int userId) async {
    final query = select(permissionsTable).join([
      innerJoin(
        rolePermissionsTable,
        rolePermissionsTable.permissionId.equalsExp(permissionsTable.id),
      ),
      innerJoin(
        rolesTable,
        rolesTable.id.equalsExp(rolePermissionsTable.roleId),
      ),
      innerJoin(
        userLoginsTable,
        userLoginsTable.roleId.equalsExp(rolesTable.id),
      ),
    ])..where(userLoginsTable.id.equals(userId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(permissionsTable)).toList();
  }
}

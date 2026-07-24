import 'dart:async';
import 'package:drift/drift.dart';
import '../../../database/coozy_database.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final UserLoginsDao userLoginsDao;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.userLoginsDao,
  });

  @override
  Future<User?> login({required String email, required String password}) async {
    // Hardcoded credentials for development
    const String hardcodedEmail = 'admin@coozy.com';
    const String hardcodedPassword = 'admin123';

    if (email != hardcodedEmail || password != hardcodedPassword) {
      return null;
    }

    // Map roles based on email input to simulate backend role assignment.
    domain.UserRole role = domain.UserRole.admin;
    final lowerEmail = email.toLowerCase();

    if (lowerEmail.contains('admin')) {
      role = domain.UserRole.admin;
    } else if (lowerEmail.contains('owner')) {
      role = domain.UserRole.owner;
    } else if (lowerEmail.contains('manager')) {
      role = domain.UserRole.manager;
    } else if (lowerEmail.contains('waiter')) {
      role = domain.UserRole.waiter;
    } else if (lowerEmail.contains('cashier')) {
      role = domain.UserRole.cashier;
    } else if (lowerEmail.contains('staff')) {
      role = domain.UserRole.staff;
    }

    final user = User(email: email, role: role);

    // Save to SharedPreferences for later purposes
    await localDataSource.saveLoginState(true);
    await localDataSource.saveUserRole(role.name);

    return user;
  }

  @override
  Future<domain.UserRole> getCurrentUserRole() async {
    final roleString = localDataSource.getUserRole();
    return domain.UserRole.fromString(roleString);
  }

  @override
  Future<bool> checkAuthStatus() async {
    return localDataSource.getLoginState();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clear();
  }

  @override
  Future<int> registerSuperUser({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    // 1. Create the "superuser" role if it doesn't exist
    final existingRoles = await userLoginsDao.getAllRoles();
    int superUserRoleId;

    final existingSuperRole = existingRoles
        .where((r) => r.name.toLowerCase() == 'superuser')
        .toList();

    if (existingSuperRole.isNotEmpty) {
      superUserRoleId = existingSuperRole.first.id;
    } else {
      superUserRoleId = await userLoginsDao.createRole(
        RolesTableCompanion(
          name: const Value('superuser'),
          description: const Value('Super User with all privileges'),
        ),
      );
    }

    // 2. Assign all permissions to the superuser role
    final allPermissions = await userLoginsDao.getAllPermissions();
    for (final permission in allPermissions) {
      try {
        await userLoginsDao.assignPermissionToRole(
          superUserRoleId,
          permission.id,
        );
      } catch (_) {
        // Permission already assigned — ignore conflict
      }
    }

    // 3. Create the user login entry if not exists
    final existingUser = await userLoginsDao.getUserByUsernameOrEmail(email);
    if (existingUser != null) {
      // Update to superuser role if not already
      await userLoginsDao.updateUser(
        existingUser.id,
        UserLoginsTableCompanion(
          roleId: Value(superUserRoleId),
          updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
        ),
      );
      return existingUser.id;
    }

    // Create new user with superuser role
    final userId = await userLoginsDao.createUserLogin(
      UserLoginsTableCompanion(
        firstName: Value(firstName),
        lastName: Value(lastName),
        username: Value(email),
        email: Value(email),
        passwordHash: const Value(
          '',
        ), // Not storing actual password in local DB
        roleId: Value(superUserRoleId),
      ),
    );

    // 4. Save superuser flag in SharedPreferences
    await localDataSource.saveSuperUserFlag(true);

    return userId;
  }
}

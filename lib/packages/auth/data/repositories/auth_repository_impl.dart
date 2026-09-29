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
    final storedEmail = await localDataSource.getStoredEmail();
    final isPasswordValid = await localDataSource.verifyPassword(password);

    if (email.trim().toLowerCase() != storedEmail.trim().toLowerCase() ||
        !isPasswordValid) {
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

  @override
  Future<bool> sendPasswordResetEmail({
    required String email,
    String? temporaryPassword,
  }) async {
    // In a production backend environment, an email service (SMTP/SES/SendGrid)
    // sends the generated random temporary password to the user's email.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (temporaryPassword != null && temporaryPassword.isNotEmpty) {
      await localDataSource.savePassword(temporaryPassword);
    }
    final user = await userLoginsDao.getUserByUsernameOrEmail(email);
    if (user != null && temporaryPassword != null && temporaryPassword.isNotEmpty) {
      // Store temporary password hash in DB if user exists
      await userLoginsDao.updatePassword(user.id, temporaryPassword);
    }
    return true;
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String temporaryPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await localDataSource.savePassword(newPassword);
    final user = await userLoginsDao.getUserByUsernameOrEmail(email);
    if (user != null) {
      return userLoginsDao.updatePassword(user.id, newPassword);
    }
    return true;
  }

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final isOldPasswordValid =
        await localDataSource.verifyPassword(oldPassword);
    if (!isOldPasswordValid) {
      return false;
    }
    await localDataSource.savePassword(newPassword);
    return true;
  }
}

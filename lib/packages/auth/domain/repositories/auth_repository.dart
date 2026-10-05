import '../entities/user.dart';
import '../entities/user_role.dart';

abstract class AuthRepository {
  Future<User?> login({required String email, required String password});
  Future<UserRole> getCurrentUserRole();
  Future<bool> checkAuthStatus();
  Future<void> logout();

  /// Registers the logged-in user as a superuser with all permissions in the local DB.
  Future<int> registerSuperUser({
    required String email,
    required String firstName,
    required String lastName,
  });

  /// Sends a temporary password to the user's registered email address.
  Future<bool> sendPasswordResetEmail({
    required String email,
    String? temporaryPassword,
  });

  /// Resets user password to [newPassword] using [temporaryPassword].
  Future<bool> resetPassword({
    required String email,
    required String temporaryPassword,
    required String newPassword,
  });

  /// Changes the user's password from [oldPassword] to [newPassword].
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

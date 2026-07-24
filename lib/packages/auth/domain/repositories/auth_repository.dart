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
}

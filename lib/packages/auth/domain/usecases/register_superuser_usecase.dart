import '../repositories/auth_repository.dart';

/// Registers the logged-in user as a superuser with all permissions in the local DB.
class RegisterSuperUserUseCase {
  final AuthRepository repository;

  RegisterSuperUserUseCase(this.repository);

  Future<int> call({
    required String email,
    required String firstName,
    required String lastName,
  }) {
    return repository.registerSuperUser(
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
  }
}

import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<bool> call({
    required String email,
    required String temporaryPassword,
    required String newPassword,
  }) {
    return repository.resetPassword(
      email: email,
      temporaryPassword: temporaryPassword,
      newPassword: newPassword,
    );
  }
}

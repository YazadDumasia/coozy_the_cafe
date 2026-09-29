import '../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  Future<bool> call({required String email, String? temporaryPassword}) {
    return repository.sendPasswordResetEmail(
      email: email,
      temporaryPassword: temporaryPassword,
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/auth/domain/usecases/reset_password_usecase.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordUseCase resetPasswordUseCase;

  ResetPasswordCubit({required this.resetPasswordUseCase})
    : super(ResetPasswordInitial());

  Future<void> submitResetPassword({
    required String email,
    required String mailPassword,
    required String newPassword,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔐 [DEBUG] Reset Password Attempt\n'
        '   📧 Email         : $email\n'
        '   🔑 Mail Password : $mailPassword\n'
        '   ⚠️  This log is ONLY visible in debug mode and is stripped in release builds.',
      );
    }
    emit(ResetPasswordLoading());
    try {
      final success = await resetPasswordUseCase(
        email: email.trim(),
        temporaryPassword: mailPassword,
        newPassword: newPassword,
      );
      if (success) {
        emit(ResetPasswordSuccess());
      } else {
        emit(
          const ResetPasswordFailure(
            errorMessage: 'Failed to reset password. Please check the password provided via mail and try again.',
          ),
        );
      }
    } catch (e) {
      emit(ResetPasswordFailure(errorMessage: e.toString()));
    }
  }

  void reset() {
    emit(ResetPasswordInitial());
  }
}

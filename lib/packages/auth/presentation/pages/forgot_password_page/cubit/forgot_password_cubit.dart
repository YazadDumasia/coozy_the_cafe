import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/auth/domain/services/password_generator.dart';
import 'package:coozy_the_cafe/packages/auth/domain/usecases/send_password_reset_email_usecase.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;

  ForgotPasswordCubit({required this.sendPasswordResetEmailUseCase})
      : super(ForgotPasswordInitial());

  Future<void> sendResetEmail(String email) async {
    emit(ForgotPasswordLoading());
    try {
      final trimmedEmail = email.trim();

      // Generate a cryptographically secure temporary password (for Reset Password page)
      final tempPassword = PasswordGenerator.generate(length: 12);

      // Generate a 4-digit OTP (for OTP Verification page)
      final otpCode =
          (math.Random.secure().nextInt(9000) + 1000).toString();

      if (kDebugMode) {
        debugPrint(
          '🔐 [DEBUG] Forgot Password — Codes Generated\n'
          '   📧 Email              : $trimmedEmail\n'
          '   🔢 OTP Code           : $otpCode\n'
          '   🔑 Temporary Password : $tempPassword\n'
          '   ⚠️  This log is ONLY visible in debug mode and stripped in release builds.',
        );
      }

      final success = await sendPasswordResetEmailUseCase(
        email: trimmedEmail,
        temporaryPassword: tempPassword,
      );
      if (success) {
        emit(ForgotPasswordEmailSentSuccess(
          email: trimmedEmail,
          temporaryPassword: tempPassword,
          otpCode: otpCode,
        ));
      } else {
        emit(
          const ForgotPasswordFailure(
            errorMessage: 'Failed to send reset email. Please try again.',
          ),
        );
      }
    } catch (e) {
      emit(ForgotPasswordFailure(errorMessage: e.toString()));
    }
  }

  void reset() {
    emit(ForgotPasswordInitial());
  }
}

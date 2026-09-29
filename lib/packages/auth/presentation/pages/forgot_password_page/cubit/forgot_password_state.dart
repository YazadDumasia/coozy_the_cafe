part of 'forgot_password_cubit.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordEmailSentSuccess extends ForgotPasswordState {
  final String email;
  final String temporaryPassword;
  final String otpCode;

  const ForgotPasswordEmailSentSuccess({
    required this.email,
    required this.temporaryPassword,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [email, temporaryPassword, otpCode];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String errorMessage;

  const ForgotPasswordFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

part of 'reset_password_cubit.dart';

sealed class ResetPasswordState extends Equatable {
  const ResetPasswordState();

  @override
  List<Object?> get props => [];
}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordLoading extends ResetPasswordState {}

class ResetPasswordSuccess extends ResetPasswordState {}

class ResetPasswordFailure extends ResetPasswordState {
  final String errorMessage;

  const ResetPasswordFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

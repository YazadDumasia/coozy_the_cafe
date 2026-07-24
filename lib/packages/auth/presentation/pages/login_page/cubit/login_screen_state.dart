part of 'login_screen_cubit.dart';

@immutable
sealed class LoginScreenState extends Equatable {}

class LoginScreenInitialState extends LoginScreenState {
  @override
  List<Object> get props => <Object>[];
}

class LoginScreenLoadingState extends LoginScreenState {
  @override
  List<Object> get props => <Object>[];
}

class LoginScreenLoadedState extends LoginScreenState {
  @override
  List<Object> get props => <Object>[];
}

class LoginScreenNoInternetState extends LoginScreenState {
  @override
  List<Object> get props => <Object>[];
}

class LoginScreenSuccessState extends LoginScreenState {
  final String email;
  final String role;

  LoginScreenSuccessState({required this.email, required this.role});

  @override
  List<Object> get props => [email, role];
}

class LoginScreenFailureState extends LoginScreenState {
  final String errorMessage;

  LoginScreenFailureState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class LoginScreenOnboardingState extends LoginScreenState {
  @override
  List<Object> get props => <Object>[];
}

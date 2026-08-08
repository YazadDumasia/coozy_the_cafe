part of 'login_with_phone_cubit.dart';

sealed class LoginWithPhoneState extends Equatable {
  const LoginWithPhoneState();
}

class LoginWithPhoneInitial extends LoginWithPhoneState {
  @override
  List<Object> get props => <Object>[];
}

class LoginWithPhoneLoadingState extends LoginWithPhoneState {
  @override
  List<Object> get props => <Object>[];
}

class LoginWithPhoneLoadedState extends LoginWithPhoneState {
  @override
  List<Object> get props => <Object>[];
}

class LoginWithPhoneErrorState extends LoginWithPhoneState {
  const LoginWithPhoneErrorState(this.errorMsg);
  final String? errorMsg;

  @override
  List<Object> get props => <Object>[errorMsg!];
}

class LoginWithPhoneNoInternetState extends LoginWithPhoneState {
  @override
  List<Object> get props => <Object>[];
}

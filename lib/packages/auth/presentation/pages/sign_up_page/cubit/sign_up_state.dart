part of 'sign_up_cubit.dart';

sealed class SignUpState extends Equatable {
  const SignUpState();
}

class SignUpInitial extends SignUpState {
  @override
  List<Object> get props => <Object>[];
}

class SignUpLoadingState extends SignUpState {
  @override
  List<Object> get props => <Object>[];
}

class SignUpLoadedState extends SignUpState {
  @override
  List<Object> get props => <Object>[];
}

class SignUpErrorState extends SignUpState {
  const SignUpErrorState(this.errorMsg);
  final String? errorMsg;

  @override
  List<Object> get props => <Object>[errorMsg ?? ''];
}

class SignUpNoInternetState extends SignUpState {
  @override
  List<Object> get props => <Object>[];
}

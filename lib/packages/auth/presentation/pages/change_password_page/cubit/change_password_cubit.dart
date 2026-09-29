import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/auth/domain/usecases/change_password_usecase.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordUseCase changePasswordUseCase;

  ChangePasswordCubit({required this.changePasswordUseCase})
      : super(ChangePasswordInitial());

  Future<void> submitChangePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(ChangePasswordLoading());
    try {
      final success = await changePasswordUseCase(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      if (success) {
        emit(ChangePasswordSuccess());
      } else {
        emit(
          const ChangePasswordFailure(
            errorMessage: 'The current password you entered is incorrect.',
          ),
        );
      }
    } catch (e) {
      emit(ChangePasswordFailure(errorMessage: e.toString()));
    }
  }

  void reset() {
    emit(ChangePasswordInitial());
  }
}

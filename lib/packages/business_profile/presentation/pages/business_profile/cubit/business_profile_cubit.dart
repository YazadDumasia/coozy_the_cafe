import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/business_profile_entity.dart';
import '../../../../domain/usecases/get_business_profile_usecase.dart';
import '../../../../domain/usecases/save_business_profile_usecase.dart';

part 'business_profile_state.dart';

class BusinessProfileCubit extends Cubit<BusinessProfileState> {
  final GetBusinessProfileUseCase getBusinessProfileUseCase;
  final SaveBusinessProfileUseCase saveBusinessProfileUseCase;

  BusinessProfileCubit({
    required this.getBusinessProfileUseCase,
    required this.saveBusinessProfileUseCase,
  }) : super(const BusinessProfileInitial());

  Future<void> loadProfile() async {
    emit(const BusinessProfileLoading());
    final result = await getBusinessProfileUseCase();
    result.fold(
      (failure) => emit(BusinessProfileError(errorMessage: failure.message)),
      (profile) => emit(BusinessProfileLoaded(profile: profile)),
    );
  }

  Future<void> updateProfile(BusinessProfileEntity updatedProfile) async {
    emit(BusinessProfileSaving(profile: updatedProfile));
    final result = await saveBusinessProfileUseCase(updatedProfile);
    result.fold(
      (failure) => emit(BusinessProfileError(errorMessage: failure.message)),
      (_) => emit(BusinessProfileSavedSuccess(profile: updatedProfile)),
    );
  }
}

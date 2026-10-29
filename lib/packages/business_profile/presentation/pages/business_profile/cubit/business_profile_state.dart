part of 'business_profile_cubit.dart';

sealed class BusinessProfileState extends Equatable {
  const BusinessProfileState();

  @override
  List<Object?> get props => [];
}

class BusinessProfileInitial extends BusinessProfileState {
  const BusinessProfileInitial();
}

class BusinessProfileLoading extends BusinessProfileState {
  const BusinessProfileLoading();
}

class BusinessProfileLoaded extends BusinessProfileState {
  final BusinessProfileEntity profile;

  const BusinessProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class BusinessProfileSaving extends BusinessProfileState {
  final BusinessProfileEntity profile;

  const BusinessProfileSaving({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class BusinessProfileSavedSuccess extends BusinessProfileState {
  final BusinessProfileEntity profile;

  const BusinessProfileSavedSuccess({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class BusinessProfileError extends BusinessProfileState {
  final String errorMessage;

  const BusinessProfileError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

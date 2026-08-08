part of 'home_cubit.dart';

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String message;

  const HomeLoaded({required this.message});
}

class HomeError extends HomeState {
  final String errorMessage;

  const HomeError({required this.errorMessage});
}

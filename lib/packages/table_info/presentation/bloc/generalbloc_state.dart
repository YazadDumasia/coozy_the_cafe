part of 'generalbloc_bloc.dart';

sealed class GeneralblocState extends Equatable {
  const GeneralblocState();
  
  @override
  List<Object> get props => [];
}

final class GeneralblocInitial extends GeneralblocState {}

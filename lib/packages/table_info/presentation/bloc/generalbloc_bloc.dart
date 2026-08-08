import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'generalbloc_event.dart';
part 'generalbloc_state.dart';

class GeneralblocBloc extends Bloc<GeneralblocEvent, GeneralblocState> {
  GeneralblocBloc() : super(GeneralblocInitial()) {
    on<GeneralblocEvent>((event, emit) {});
  }
}

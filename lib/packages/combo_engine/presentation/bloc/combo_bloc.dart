import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:coozy_the_cafe/packages/core/coozy_core.dart';

import '../../domain/entities/combo.dart';
import '../../domain/usecases/combo_usecases.dart';

part 'combo_event.dart';
part 'combo_state.dart';

class ComboBloc extends Bloc<ComboEvent, ComboState> {
  final GetCombosUseCase getCombosUseCase;
  final WatchCombosUseCase watchCombosUseCase;
  final CreateComboUseCase createComboUseCase;
  final UpdateComboUseCase updateComboUseCase;
  final DeleteComboUseCase deleteComboUseCase;
  final ToggleComboStatusUseCase toggleComboStatusUseCase;
  final UpdateComboSortOrdersUseCase updateComboSortOrdersUseCase;

  ComboBloc({
    required this.getCombosUseCase,
    required this.watchCombosUseCase,
    required this.createComboUseCase,
    required this.updateComboUseCase,
    required this.deleteComboUseCase,
    required this.toggleComboStatusUseCase,
    required this.updateComboSortOrdersUseCase,
  }) : super(const ComboInitialState()) {
    on<LoadCombosEvent>(_onLoadCombos);
    on<SaveComboEvent>(_onSaveCombo);
    on<DeleteComboEvent>(_onDeleteCombo);
    on<ToggleComboStatusEvent>(_onToggleComboStatus);
    on<ReorderCombosEvent>(_onReorderCombos);
  }

  Future<void> _onLoadCombos(
    LoadCombosEvent event,
    Emitter<ComboState> emit,
  ) async {
    PlatformUtils.debugLog(
      ComboBloc,
      '_onLoadCombos: query="${event.searchQuery}", onlyActive=${event.onlyActive}, limit=${event.limit}, offset=${event.offset}',
    );
    emit(const ComboLoadingState());

    await emit.forEach<Either<Failure, List<Combo>>>(
      watchCombosUseCase(
        searchQuery: event.searchQuery,
        onlyActive: event.onlyActive,
        limit: event.limit,
        offset: event.offset,
      ),
      onData: (either) {
        return either.fold(
          (failure) {
            PlatformUtils.debugLog(
              ComboBloc,
              '_onLoadCombos watch failed: ${failure.message}',
            );
            return ComboErrorState(failure.message);
          },
          (combos) {
            PlatformUtils.debugLog(
              ComboBloc,
              '_onLoadCombos watch received ${combos.length} combos',
            );
            return ComboLoadedState(
              combos: combos,
              searchQuery: event.searchQuery,
              hasReachedMax: combos.length < event.limit,
            );
          },
        );
      },
      onError: (error, stackTrace) {
        PlatformUtils.debugLog(ComboBloc, '_onLoadCombos stream error: $error');
        return ComboErrorState(error.toString());
      },
    );
  }

  Future<void> _onSaveCombo(
    SaveComboEvent event,
    Emitter<ComboState> emit,
  ) async {
    final combo = event.combo;
    PlatformUtils.debugLog(
      ComboBloc,
      '_onSaveCombo: name="${combo.name}", items=${combo.items.length}, id=${combo.id}',
    );
    if (combo.id == null) {
      final res = await createComboUseCase(combo);
      res.fold(
        (failure) {
          PlatformUtils.debugLog(
            ComboBloc,
            '_onSaveCombo create failed: ${failure.message}',
          );
          emit(ComboErrorState(failure.message));
        },
        (id) {
          PlatformUtils.debugLog(
            ComboBloc,
            '_onSaveCombo created combo with id=$id',
          );
          emit(const ComboActionSuccessState('Combo created successfully'));
        },
      );
    } else {
      final res = await updateComboUseCase(combo);
      res.fold(
        (failure) {
          PlatformUtils.debugLog(
            ComboBloc,
            '_onSaveCombo update failed: ${failure.message}',
          );
          emit(ComboErrorState(failure.message));
        },
        (success) {
          PlatformUtils.debugLog(
            ComboBloc,
            '_onSaveCombo updated combo with id=${combo.id}',
          );
          emit(const ComboActionSuccessState('Combo updated successfully'));
        },
      );
    }
  }

  Future<void> _onDeleteCombo(
    DeleteComboEvent event,
    Emitter<ComboState> emit,
  ) async {
    PlatformUtils.debugLog(ComboBloc, '_onDeleteCombo: id=${event.id}');
    final res = await deleteComboUseCase(event.id);
    res.fold(
      (failure) {
        PlatformUtils.debugLog(
          ComboBloc,
          '_onDeleteCombo failed: ${failure.message}',
        );
        emit(ComboErrorState(failure.message));
      },
      (success) {
        PlatformUtils.debugLog(
          ComboBloc,
          '_onDeleteCombo success: id=${event.id}',
        );
        emit(const ComboActionSuccessState('Combo deleted successfully'));
      },
    );
  }

  Future<void> _onToggleComboStatus(
    ToggleComboStatusEvent event,
    Emitter<ComboState> emit,
  ) async {
    PlatformUtils.debugLog(
      ComboBloc,
      '_onToggleComboStatus: id=${event.id}, isActive=${event.isActive}',
    );
    final res = await toggleComboStatusUseCase(event.id, event.isActive);
    res.fold(
      (failure) {
        PlatformUtils.debugLog(
          ComboBloc,
          '_onToggleComboStatus failed: ${failure.message}',
        );
        emit(ComboErrorState(failure.message));
      },
      (success) {
        PlatformUtils.debugLog(
          ComboBloc,
          '_onToggleComboStatus success: id=${event.id}, isActive=${event.isActive}',
        );
        emit(
          ComboActionSuccessState(
            event.isActive ? 'Combo activated' : 'Combo deactivated',
          ),
        );
      },
    );
  }

  Future<void> _onReorderCombos(
    ReorderCombosEvent event,
    Emitter<ComboState> emit,
  ) async {
    if (state is! ComboLoadedState) return;

    final currentState = state as ComboLoadedState;
    final list = List<Combo>.from(currentState.combos);

    if (event.oldIndex < 0 || event.oldIndex >= list.length) return;
    final int insertIndex = event.newIndex.clamp(0, list.length - 1);

    final item = list.removeAt(event.oldIndex);
    list.insert(insertIndex, item);

    // Optimistically update loaded state
    emit(currentState.copyWith(combos: list));

    PlatformUtils.debugLog(
      ComboBloc,
      '_onReorderCombos: oldIndex=${event.oldIndex}, insertIndex=$insertIndex',
    );

    final res = await updateComboSortOrdersUseCase(list);
    res.fold(
      (failure) {
        PlatformUtils.debugLog(
          ComboBloc,
          '_onReorderCombos failed: ${failure.message}',
        );
        emit(ComboErrorState(failure.message));
        emit(currentState); // Revert on failure
      },
      (success) {
        PlatformUtils.debugLog(
          ComboBloc,
          '_onReorderCombos success: updated sort order for ${list.length} combos',
        );
      },
    );
  }
}

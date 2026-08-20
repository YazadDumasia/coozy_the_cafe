import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/inventory_item.dart';
import '../../../domain/usecases/inventory_usecases.dart';

part 'inventory_picker_event.dart';
part 'inventory_picker_state.dart';

class InventoryPickerBloc
    extends Bloc<InventoryPickerEvent, InventoryPickerState> {
  final GetInventoryItemsPagedUseCase getInventoryItemsPagedUseCase;
  static const int _limit = 20;

  InventoryPickerBloc({required this.getInventoryItemsPagedUseCase})
    : super(const InventoryPickerState()) {
    on<LoadInventoryPickerItems>(_onLoadInventoryPickerItems);
  }

  Future<void> _onLoadInventoryPickerItems(
    LoadInventoryPickerItems event,
    Emitter<InventoryPickerState> emit,
  ) async {
    if (state.hasReachedMax &&
        !event.isRefresh &&
        event.searchQuery == state.searchQuery) {
      return;
    }

    try {
      if (event.isRefresh ||
          (event.searchQuery != null &&
              event.searchQuery != state.searchQuery)) {
        emit(
          state.copyWith(
            isLoading: true,
            items: [],
            hasReachedMax: false,
            errorMessage: null,
            searchQuery: event.searchQuery ?? '',
          ),
        );
        final items = await getInventoryItemsPagedUseCase(
          _limit,
          0,
          event.searchQuery,
        );
        emit(
          state.copyWith(
            isLoading: false,
            items: items,
            hasReachedMax: items.length < _limit,
            searchQuery: event.searchQuery ?? '',
          ),
        );
      } else {
        emit(state.copyWith(isLoading: true, errorMessage: null));
        final items = await getInventoryItemsPagedUseCase(
          _limit,
          state.items.length,
          state.searchQuery,
        );
        emit(
          state.copyWith(
            isLoading: false,
            items: List.of(state.items)..addAll(items),
            hasReachedMax: items.length < _limit,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}

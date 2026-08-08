import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/inventory_usecases.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';
import '../../../shared/l10n/locale_keys.dart';
import '../../../shared/coozy_shared.dart' as shared;

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryItemsUseCase getInventoryItemsUseCase;
  final AddInventoryItemUseCase addInventoryItemUseCase;
  final UpdateInventoryItemUseCase updateInventoryItemUseCase;
  final DeleteInventoryItemUseCase deleteInventoryItemUseCase;

  InventoryBloc({
    required this.getInventoryItemsUseCase,
    required this.addInventoryItemUseCase,
    required this.updateInventoryItemUseCase,
    required this.deleteInventoryItemUseCase,
  }) : super(InventoryInitial()) {
    on<LoadInventoryItems>(_onLoadInventoryItems);
    on<AddInventoryItem>(_onAddInventoryItem);
    on<UpdateInventoryItem>(_onUpdateInventoryItem);
    on<DeleteInventoryItem>(_onDeleteInventoryItem);
  }

  Future<void> _onLoadInventoryItems(
    LoadInventoryItems event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final items = await getInventoryItemsUseCase();
      shared.SuspensionUtil.sortListBySuspensionTag(items);
      shared.SuspensionUtil.setShowSuspensionStatus(items);
      emit(InventoryLoaded(items));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onAddInventoryItem(
    AddInventoryItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await addInventoryItemUseCase(event.item);
      event.onSuccess?.call();
      add(LoadInventoryItems());
    } catch (e) {
      event.onError?.call(LocaleKeys.crudErrorAdd);
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onUpdateInventoryItem(
    UpdateInventoryItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await updateInventoryItemUseCase(event.item);
      event.onSuccess?.call();
      add(LoadInventoryItems());
    } catch (e) {
      event.onError?.call(LocaleKeys.crudErrorUpdate);
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onDeleteInventoryItem(
    DeleteInventoryItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await deleteInventoryItemUseCase(event.id);
      event.onSuccess?.call();
      add(LoadInventoryItems());
    } catch (e) {
      event.onError?.call(LocaleKeys.crudErrorDelete);
      emit(InventoryError(e.toString()));
    }
  }
}

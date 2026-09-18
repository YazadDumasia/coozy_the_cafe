import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/inventory_item.dart';
import '../../../domain/usecases/inventory_usecases.dart';
import '../../../../shared/l10n/locale_keys.dart';
import '../../../../shared/coozy_shared.dart' as shared;

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryItemsUseCase getInventoryItemsUseCase;
  final AddInventoryItemUseCase addInventoryItemUseCase;
  final UpdateInventoryItemUseCase updateInventoryItemUseCase;
  final DeleteInventoryItemUseCase deleteInventoryItemUseCase;
  final AdjustInventoryStockUseCase adjustInventoryStockUseCase;

  InventoryBloc({
    required this.getInventoryItemsUseCase,
    required this.addInventoryItemUseCase,
    required this.updateInventoryItemUseCase,
    required this.deleteInventoryItemUseCase,
    required this.adjustInventoryStockUseCase,
  }) : super(InventoryInitial()) {
    on<LoadInventoryItems>(_onLoadInventoryItems);
    on<AddInventoryItem>(_onAddInventoryItem);
    on<UpdateInventoryItem>(_onUpdateInventoryItem);
    on<DeleteInventoryItem>(_onDeleteInventoryItem);
    on<AdjustInventoryStock>(_onAdjustInventoryStock);
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
      if (state is InventoryLoaded) {
        final currentItems = (state as InventoryLoaded).items;
        final updatedList = currentItems.map((item) {
          return item.id == event.item.id ? event.item : item;
        }).toList();
        shared.SuspensionUtil.sortListBySuspensionTag(updatedList);
        shared.SuspensionUtil.setShowSuspensionStatus(updatedList);
        emit(InventoryLoaded(updatedList));
      } else {
        add(LoadInventoryItems());
      }
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

  Future<void> _onAdjustInventoryStock(
    AdjustInventoryStock event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      if (event.item.id == null) {
        event.onError?.call(LocaleKeys.crudErrorUpdate);
        return;
      }
      final success = await adjustInventoryStockUseCase(
        inventoryId: event.item.id!,
        adjustedQty: event.adjustedQty,
        isIncrement: event.isIncrement,
        reason: event.reason,
      );
      if (success) {
        event.onSuccess?.call();
        final prevStock = event.item.currentStock ?? 0.0;
        double nextStock = event.isIncrement
            ? (prevStock + event.adjustedQty)
            : (prevStock - event.adjustedQty);
        if (nextStock < 0) nextStock = 0;

        final updatedItem = event.item.copyWith(
          currentStock: nextStock,
          modifiedDate: DateTime.now().toIso8601String(),
        );

        if (state is InventoryLoaded) {
          final currentItems = (state as InventoryLoaded).items;
          final updatedList = currentItems.map((item) {
            return item.id == updatedItem.id ? updatedItem : item;
          }).toList();
          shared.SuspensionUtil.sortListBySuspensionTag(updatedList);
          shared.SuspensionUtil.setShowSuspensionStatus(updatedList);
          emit(InventoryLoaded(updatedList));
        } else {
          add(LoadInventoryItems());
        }
      } else {
        event.onError?.call(LocaleKeys.crudErrorUpdate);
      }
    } catch (e) {
      event.onError?.call(LocaleKeys.crudErrorUpdate);
      emit(InventoryError(e.toString()));
    }
  }
}

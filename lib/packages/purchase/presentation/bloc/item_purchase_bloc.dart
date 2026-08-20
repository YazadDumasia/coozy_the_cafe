import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/purchase_record.dart';
import '../../domain/usecases/purchase_usecases.dart';
import '../../../inventory/domain/entities/inventory_item.dart';

part 'item_purchase_event.dart';
part 'item_purchase_state.dart';

class ItemPurchaseBloc extends Bloc<ItemPurchaseEvent, ItemPurchaseState> {
  final GetPurchasesUseCase getPurchasesUseCase;
  final AddPurchaseRecordUseCase addPurchaseRecordUseCase;

  ItemPurchaseBloc({
    required this.getPurchasesUseCase,
    required this.addPurchaseRecordUseCase,
  }) : super(ItemPurchaseInitial()) {
    on<LoadPurchasesForInventory>(_onLoadPurchasesForInventory);
    on<AddPurchaseRecord>(_onAddPurchaseRecord);
  }

  Future<void> _onLoadPurchasesForInventory(
    LoadPurchasesForInventory event,
    Emitter<ItemPurchaseState> emit,
  ) async {
    emit(ItemPurchaseLoading());
    try {
      final purchases = await getPurchasesUseCase(event.item.id!);
      emit(ItemPurchasesLoaded(item: event.item, purchases: purchases));
    } catch (e) {
      emit(ItemPurchaseError(e.toString()));
    }
  }

  Future<void> _onAddPurchaseRecord(
    AddPurchaseRecord event,
    Emitter<ItemPurchaseState> emit,
  ) async {
    try {
      await addPurchaseRecordUseCase(event.record);
      // Reload purchases for the specific item
      if (event.record.inventoryId != null) {
        final purchases = await getPurchasesUseCase(event.record.inventoryId!);
        final currentState = state;
        if (currentState is ItemPurchasesLoaded) {
          emit(
            ItemPurchasesLoaded(item: currentState.item, purchases: purchases),
          );
        }
      }
      event.onSuccess?.call();
    } catch (e) {
      event.onError?.call(e.toString());
      emit(ItemPurchaseError(e.toString()));
    }
  }
}

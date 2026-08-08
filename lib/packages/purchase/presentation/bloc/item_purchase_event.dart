import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/purchase_record.dart';
import '../../../inventory/domain/entities/inventory_item.dart';

sealed class ItemPurchaseEvent extends Equatable {
  const ItemPurchaseEvent();
  @override
  List<Object?> get props => [];
}

class LoadPurchasesForInventory extends ItemPurchaseEvent {
  final InventoryItem item;
  const LoadPurchasesForInventory(this.item);
  @override
  List<Object?> get props => [item];
}

class AddPurchaseRecord extends ItemPurchaseEvent {
  final PurchaseRecord record;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const AddPurchaseRecord(this.record, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [record];
}

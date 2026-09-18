part of 'inventory_bloc.dart';

sealed class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventoryItems extends InventoryEvent {}

class AddInventoryItem extends InventoryEvent {
  final InventoryItem item;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const AddInventoryItem(this.item, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [item];
}

class UpdateInventoryItem extends InventoryEvent {
  final InventoryItem item;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const UpdateInventoryItem(this.item, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [item];
}

class DeleteInventoryItem extends InventoryEvent {
  final int id;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const DeleteInventoryItem(this.id, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [id];
}

class AdjustInventoryStock extends InventoryEvent {
  final InventoryItem item;
  final double adjustedQty;
  final bool isIncrement;
  final String? reason;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const AdjustInventoryStock({
    required this.item,
    required this.adjustedQty,
    required this.isIncrement,
    this.reason,
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [item, adjustedQty, isIncrement, reason];
}

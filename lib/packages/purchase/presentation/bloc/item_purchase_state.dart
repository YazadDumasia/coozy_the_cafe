part of 'item_purchase_bloc.dart';

sealed class ItemPurchaseState extends Equatable {
  const ItemPurchaseState();
  @override
  List<Object?> get props => [];
}

class ItemPurchaseInitial extends ItemPurchaseState {}

class ItemPurchaseLoading extends ItemPurchaseState {}

class ItemPurchasesLoaded extends ItemPurchaseState {
  final InventoryItem item;
  final List<PurchaseRecord> purchases;

  const ItemPurchasesLoaded({required this.item, required this.purchases});

  @override
  List<Object?> get props => [item, purchases];
}

class ItemPurchaseError extends ItemPurchaseState {
  final String message;
  const ItemPurchaseError(this.message);
  @override
  List<Object?> get props => [message];
}

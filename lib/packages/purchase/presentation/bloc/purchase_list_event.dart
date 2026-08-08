import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/purchase_record.dart';

sealed class PurchaseListEvent extends Equatable {
  const PurchaseListEvent();

  @override
  List<Object?> get props => [];
}

class LoadPurchases extends PurchaseListEvent {
  final bool isRefresh;
  final String? searchQuery;

  const LoadPurchases({this.isRefresh = false, this.searchQuery});

  @override
  List<Object?> get props => [isRefresh, searchQuery];
}

class AddPurchaseRecordFromList extends PurchaseListEvent {
  final PurchaseRecord record;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const AddPurchaseRecordFromList(this.record, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [record];
}

class UpdatePurchaseRecord extends PurchaseListEvent {
  final PurchaseRecord record;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const UpdatePurchaseRecord(this.record, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [record];
}

class DeletePurchaseRecord extends PurchaseListEvent {
  final int id;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const DeletePurchaseRecord(this.id, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [id];
}

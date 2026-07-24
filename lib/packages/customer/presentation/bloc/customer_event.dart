import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/customer_entity.dart';

sealed class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {
  final bool isRefresh;
  final String? searchQuery;

  const LoadCustomers({this.isRefresh = false, this.searchQuery});

  @override
  List<Object?> get props => [isRefresh, searchQuery];
}

class AddCustomer extends CustomerEvent {
  final CustomerEntity customer;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  
  const AddCustomer(this.customer, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [customer];
}

class UpdateCustomer extends CustomerEvent {
  final CustomerEntity customer;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  
  const UpdateCustomer(this.customer, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomer extends CustomerEvent {
  final int id;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  
  const DeleteCustomer(this.id, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [id];
}

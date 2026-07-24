import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';

sealed class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerEntity> customers;
  final bool hasReachedMax;

  const CustomerLoaded({required this.customers, this.hasReachedMax = false});

  CustomerLoaded copyWith({
    List<CustomerEntity>? customers,
    bool? hasReachedMax,
  }) {
    return CustomerLoaded(
      customers: customers ?? this.customers,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [customers, hasReachedMax];
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

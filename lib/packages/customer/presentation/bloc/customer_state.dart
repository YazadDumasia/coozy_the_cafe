part of 'customer_bloc.dart';

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
  final bool isLoadingMore;

  const CustomerLoaded({
    required this.customers,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  CustomerLoaded copyWith({
    List<CustomerEntity>? customers,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return CustomerLoaded(
      customers: customers ?? this.customers,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [customers, hasReachedMax, isLoadingMore];
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

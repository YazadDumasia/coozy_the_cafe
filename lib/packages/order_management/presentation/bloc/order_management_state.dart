part of 'order_management_bloc.dart';

sealed class OrderManagementState extends Equatable {
  const OrderManagementState();

  @override
  List<Object?> get props => [];
}

class OrderManagementInitialState extends OrderManagementState {
  const OrderManagementInitialState();
}

class OrderManagementLoadingState extends OrderManagementState {
  const OrderManagementLoadingState();
}

class OrderManagementLoadedState extends OrderManagementState {
  final List<OrderManagementEntity> orders;
  final int totalCount;
  final int currentPage;
  final bool hasReachedMax;
  final bool isFetchingMore;
  final String searchQuery;
  final DateTimeRange? dateRange;
  final String selectedStatus;
  final OrderManagementEntity? selectedOrderDetails;
  final bool isLoadingDetails;
  final String? errorMessage;

  const OrderManagementLoadedState({
    required this.orders,
    required this.totalCount,
    required this.currentPage,
    required this.hasReachedMax,
    this.isFetchingMore = false,
    this.searchQuery = '',
    this.dateRange,
    this.selectedStatus = 'all',
    this.selectedOrderDetails,
    this.isLoadingDetails = false,
    this.errorMessage,
  });

  OrderManagementLoadedState copyWith({
    List<OrderManagementEntity>? orders,
    int? totalCount,
    int? currentPage,
    bool? hasReachedMax,
    bool? isFetchingMore,
    String? searchQuery,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    String? selectedStatus,
    OrderManagementEntity? selectedOrderDetails,
    bool clearOrderDetails = false,
    bool? isLoadingDetails,
    String? errorMessage,
  }) {
    return OrderManagementLoadedState(
      orders: orders ?? this.orders,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedOrderDetails: clearOrderDetails
          ? null
          : (selectedOrderDetails ?? this.selectedOrderDetails),
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        totalCount,
        currentPage,
        hasReachedMax,
        isFetchingMore,
        searchQuery,
        dateRange,
        selectedStatus,
        selectedOrderDetails,
        isLoadingDetails,
        errorMessage,
      ];
}

class OrderManagementErrorState extends OrderManagementState {
  final String message;

  const OrderManagementErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/customer_usecases.dart';
import '../../../shared/coozy_shared.dart' as shared;

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final AddCustomerUseCase addCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;

  int _currentPage = 1;
  static const int _limit = 20;
  String? _currentSearchQuery;

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.addCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
  }) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    if (event.isRefresh) {
      _currentPage = 1;
      _currentSearchQuery = event.searchQuery;
      emit(CustomerLoading());
    } else {
      if (state is CustomerLoaded) {
        final current = state as CustomerLoaded;
        if (current.hasReachedMax || current.isLoadingMore) return;
        emit(current.copyWith(isLoadingMore: true));
      } else {
        emit(CustomerLoading());
      }
    }

    try {
      //just lodad delay
      // await Future.delayed(const Duration(seconds: 2));
      final customers = await getCustomersUseCase(
        limit: _limit,
        pageNumber: _currentPage,
        search: _currentSearchQuery,
      );

      final bool hasReachedMax = customers.length < _limit;

      List<CustomerEntity> updatedCustomers;
      if (state is CustomerLoaded && !event.isRefresh) {
        final currentCustomers = (state as CustomerLoaded).customers;
        updatedCustomers = List.of(currentCustomers)..addAll(customers);
      } else {
        updatedCustomers = customers;
      }

      shared.SuspensionUtil.sortListBySuspensionTag(updatedCustomers);
      shared.SuspensionUtil.setShowSuspensionStatus(updatedCustomers);

      emit(
        CustomerLoaded(
          customers: updatedCustomers,
          hasReachedMax: hasReachedMax,
        ),
      );

      _currentPage++;
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onAddCustomer(
    AddCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await addCustomerUseCase(event.customer);
      event.onSuccess?.call();
      add(LoadCustomers(isRefresh: true, searchQuery: _currentSearchQuery));
    } catch (e) {
      event.onError?.call(shared.LocaleKeys.crudErrorAdd);
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await updateCustomerUseCase(event.customer);
      event.onSuccess?.call();
      add(LoadCustomers(isRefresh: true, searchQuery: _currentSearchQuery));
    } catch (e) {
      event.onError?.call(shared.LocaleKeys.crudErrorUpdate);
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await deleteCustomerUseCase(event.id);
      event.onSuccess?.call();
      add(LoadCustomers(isRefresh: true, searchQuery: _currentSearchQuery));
    } catch (e) {
      event.onError?.call(shared.LocaleKeys.crudErrorDelete);
      emit(CustomerError(e.toString()));
    }
  }
}

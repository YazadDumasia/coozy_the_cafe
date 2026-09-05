import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../../domain/entities/invoice_management_entity.dart';
import '../../domain/usecases/get_paginated_invoices_usecase.dart';
import '../../domain/usecases/get_invoice_details_usecase.dart';
import '../../domain/usecases/update_invoice_usecase.dart';
import '../../domain/usecases/delete_invoice_usecase.dart';
import '../../domain/usecases/get_payment_modes_usecase.dart';

part 'invoice_management_event.dart';
part 'invoice_management_state.dart';

class InvoiceManagementBloc
    extends Bloc<InvoiceManagementEvent, InvoiceManagementState> {
  final GetPaginatedInvoicesUseCase getPaginatedInvoicesUseCase;
  final GetInvoiceDetailsUseCase getInvoiceDetailsUseCase;
  final UpdateInvoiceUseCase updateInvoiceUseCase;
  final DeleteInvoiceUseCase deleteInvoiceUseCase;
  final GetPaymentModesUseCase getPaymentModesUseCase;

  static const int pageSize = 15;

  InvoiceManagementBloc({
    required this.getPaginatedInvoicesUseCase,
    required this.getInvoiceDetailsUseCase,
    required this.updateInvoiceUseCase,
    required this.deleteInvoiceUseCase,
    required this.getPaymentModesUseCase,
  }) : super(const InvoiceManagementInitialState()) {
    on<LoadInvoicesEvent>(_onLoadInvoices);
    on<LoadMoreInvoicesEvent>(_onLoadMoreInvoices);
    on<SelectInvoiceDateRangeEvent>(_onSelectDateRange);
    on<LoadInvoiceDetailsEvent>(_onLoadInvoiceDetails);
    on<UpdateInvoiceEvent>(_onUpdateInvoice);
    on<DeleteInvoiceEvent>(_onDeleteInvoice);
  }

  Future<void> _onLoadInvoices(
    LoadInvoicesEvent event,
    Emitter<InvoiceManagementState> emit,
  ) async {
    final currentState = state;
    String query = event.searchQuery ?? '';
    DateTimeRange? range = event.dateRange;

    if (!event.isRefresh && currentState is InvoiceManagementLoadedState) {
      query = event.searchQuery ?? currentState.searchQuery;
      range = event.dateRange ?? currentState.dateRange;
    }

    if (currentState is! InvoiceManagementLoadedState || event.isRefresh) {
      emit(const InvoiceManagementLoadingState());
    }

    final modesResult = await getPaymentModesUseCase();
    List<PaymentMode> modes = [];
    modesResult.fold((_) {}, (data) => modes = data);

    final result = await getPaginatedInvoicesUseCase(
      GetPaginatedInvoicesParams(
        limit: pageSize,
        pageNo: 1,
        startDate: range?.start,
        endDate: range?.end,
        searchQuery: query,
      ),
    );

    result.fold(
      (failure) => emit(InvoiceManagementErrorState(failure.message)),
      (paginated) {
        final hasReachedMax =
            paginated.invoices.length >= paginated.totalCount;
        emit(
          InvoiceManagementLoadedState(
            invoices: paginated.invoices,
            totalCount: paginated.totalCount,
            currentPage: 1,
            hasReachedMax: hasReachedMax,
            searchQuery: query,
            dateRange: range,
            paymentModes: modes,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreInvoices(
    LoadMoreInvoicesEvent event,
    Emitter<InvoiceManagementState> emit,
  ) async {
    final currentState = state;
    if (currentState is! InvoiceManagementLoadedState) return;
    if (currentState.hasReachedMax || currentState.isFetchingMore) return;

    emit(currentState.copyWith(isFetchingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await getPaginatedInvoicesUseCase(
      GetPaginatedInvoicesParams(
        limit: pageSize,
        pageNo: nextPage,
        startDate: currentState.dateRange?.start,
        endDate: currentState.dateRange?.end,
        searchQuery: currentState.searchQuery,
      ),
    );

    result.fold(
      (failure) => emit(
        currentState.copyWith(
          isFetchingMore: false,
          errorMessage: failure.message,
        ),
      ),
      (paginated) {
        final updated = [
          ...currentState.invoices,
          ...paginated.invoices,
        ];
        final hasReachedMax = updated.length >= paginated.totalCount;

        emit(
          currentState.copyWith(
            invoices: updated,
            totalCount: paginated.totalCount,
            currentPage: nextPage,
            hasReachedMax: hasReachedMax,
            isFetchingMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onSelectDateRange(
    SelectInvoiceDateRangeEvent event,
    Emitter<InvoiceManagementState> emit,
  ) async {
    add(
      LoadInvoicesEvent(
        isRefresh: true,
        dateRange: event.dateRange,
      ),
    );
  }

  Future<void> _onLoadInvoiceDetails(
    LoadInvoiceDetailsEvent event,
    Emitter<InvoiceManagementState> emit,
  ) async {
    final currentState = state;
    if (currentState is InvoiceManagementLoadedState) {
      emit(currentState.copyWith(isLoadingDetails: true));
      final result = await getInvoiceDetailsUseCase(event.invoiceId);
      result.fold(
        (failure) => emit(
          currentState.copyWith(
            isLoadingDetails: false,
            errorMessage: failure.message,
          ),
        ),
        (details) => emit(
          currentState.copyWith(
            isLoadingDetails: false,
            selectedInvoiceDetails: details,
          ),
        ),
      );
    }
  }

  Future<void> _onUpdateInvoice(
    UpdateInvoiceEvent event,
    Emitter<InvoiceManagementState> emit,
  ) async {
    final result = await updateInvoiceUseCase(
      UpdateInvoiceParams(
        invoice: event.invoice,
        items: event.items,
      ),
    );

    result.fold(
      (failure) {
        if (state is InvoiceManagementLoadedState) {
          emit(
            (state as InvoiceManagementLoadedState).copyWith(
              errorMessage: failure.message,
            ),
          );
        }
      },
      (_) {
        emit(const InvoiceUpdatedSuccessState());
        add(const LoadInvoicesEvent(isRefresh: true));
      },
    );
  }

  Future<void> _onDeleteInvoice(
    DeleteInvoiceEvent event,
    Emitter<InvoiceManagementState> emit,
  ) async {
    final result = await deleteInvoiceUseCase(event.invoiceId);

    result.fold(
      (failure) {
        if (state is InvoiceManagementLoadedState) {
          emit(
            (state as InvoiceManagementLoadedState).copyWith(
              errorMessage: failure.message,
            ),
          );
        }
      },
      (_) {
        emit(const InvoiceDeletedSuccessState());
        add(const LoadInvoicesEvent(isRefresh: true));
      },
    );
  }
}

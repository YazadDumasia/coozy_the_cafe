import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/purchase_usecases.dart';
import 'purchase_list_event.dart';
import 'purchase_list_state.dart';

class PurchaseListBloc extends Bloc<PurchaseListEvent, PurchaseListState> {
  final GetAllPurchasesPagedUseCase getAllPurchasesPagedUseCase;
  final AddPurchaseRecordUseCase addPurchaseRecordUseCase;
  final UpdatePurchaseRecordUseCase updatePurchaseRecordUseCase;
  final DeletePurchaseRecordUseCase deletePurchaseRecordUseCase;
  final GetPurchaseSummaryUseCase getPurchaseSummaryUseCase;

  static const int _limit = 20;

  PurchaseListBloc({
    required this.getAllPurchasesPagedUseCase,
    required this.addPurchaseRecordUseCase,
    required this.updatePurchaseRecordUseCase,
    required this.deletePurchaseRecordUseCase,
    required this.getPurchaseSummaryUseCase,
  }) : super(const PurchaseListState()) {
    on<LoadPurchases>(_onLoadPurchases);
    on<AddPurchaseRecordFromList>(_onAddPurchaseRecordFromList);
    on<UpdatePurchaseRecord>(_onUpdatePurchaseRecord);
    on<DeletePurchaseRecord>(_onDeletePurchaseRecord);
  }

  Future<void> _onLoadPurchases(
    LoadPurchases event,
    Emitter<PurchaseListState> emit,
  ) async {
    if (state.hasReachedMax &&
        !event.isRefresh &&
        event.searchQuery == state.searchQuery) {
      return;
    }

    try {
      if (event.isRefresh ||
          (event.searchQuery != null &&
              event.searchQuery != state.searchQuery)) {
        emit(
          state.copyWith(
            isLoading: true,
            purchases: [],
            hasReachedMax: false,
            errorMessage: null,
            searchQuery: event.searchQuery ?? '',
          ),
        );

        final summary = await getPurchaseSummaryUseCase();
        final records = await getAllPurchasesPagedUseCase(
          _limit,
          0,
          event.searchQuery,
        );

        emit(
          state.copyWith(
            isLoading: false,
            purchases: records,
            hasReachedMax: records.length < _limit,
            searchQuery: event.searchQuery ?? '',
            purchaseSummary: summary,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: true, errorMessage: null));
        final records = await getAllPurchasesPagedUseCase(
          _limit,
          state.purchases.length,
          state.searchQuery,
        );
        emit(
          state.copyWith(
            isLoading: false,
            purchases: List.of(state.purchases)..addAll(records),
            hasReachedMax: records.length < _limit,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddPurchaseRecordFromList(
    AddPurchaseRecordFromList event,
    Emitter<PurchaseListState> emit,
  ) async {
    try {
      await addPurchaseRecordUseCase(event.record);
      event.onSuccess?.call();
      add(const LoadPurchases(isRefresh: true));
    } catch (e) {
      event.onError?.call(e.toString());
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdatePurchaseRecord(
    UpdatePurchaseRecord event,
    Emitter<PurchaseListState> emit,
  ) async {
    try {
      await updatePurchaseRecordUseCase(event.record);
      event.onSuccess?.call();
      add(const LoadPurchases(isRefresh: true));
    } catch (e) {
      event.onError?.call(e.toString());
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeletePurchaseRecord(
    DeletePurchaseRecord event,
    Emitter<PurchaseListState> emit,
  ) async {
    try {
      await deletePurchaseRecordUseCase(event.id);
      event.onSuccess?.call();
      add(const LoadPurchases(isRefresh: true));
    } catch (e) {
      event.onError?.call(e.toString());
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}

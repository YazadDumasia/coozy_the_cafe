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
    final effectiveQuery = event.searchQuery ?? '';
    if (state.hasReachedMax &&
        !event.isRefresh &&
        effectiveQuery == state.searchQuery) {
      return;
    }

    try {
      if (event.isRefresh ||
          (effectiveQuery.isNotEmpty && effectiveQuery != state.searchQuery)) {
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
      final id = await addPurchaseRecordUseCase(event.record);
      event.onSuccess?.call();

      final newRecord = event.record.copyWith(id: id);
      final updatedPurchases = [newRecord, ...state.purchases];
      final summary = await getPurchaseSummaryUseCase();

      emit(
        state.copyWith(purchases: updatedPurchases, purchaseSummary: summary),
      );
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

      final updatedPurchases = state.purchases.map((e) {
        return e.id == event.record.id ? event.record : e;
      }).toList();
      final summary = await getPurchaseSummaryUseCase();

      emit(
        state.copyWith(purchases: updatedPurchases, purchaseSummary: summary),
      );
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

      final updatedPurchases = state.purchases
          .where((e) => e.id != event.id)
          .toList();
      final summary = await getPurchaseSummaryUseCase();

      emit(
        state.copyWith(purchases: updatedPurchases, purchaseSummary: summary),
      );
    } catch (e) {
      event.onError?.call(e.toString());
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}

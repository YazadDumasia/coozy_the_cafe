import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/menu_subcategory.dart';
import '../../domain/usecases/menu_subcategory_usecases.dart';
import 'menu_subcategory_event.dart';
import 'menu_subcategory_state.dart';
import '../../../shared/coozy_shared.dart' as shared;

class MenuSubcategoryBloc
    extends Bloc<MenuSubcategoryEvent, MenuSubcategoryState> {
  final GetMenuSubcategoriesUseCase getSubcategoriesUseCase;
  final GetMenuSubcategoriesByCategoryUseCase getSubcategoriesByCategoryUseCase;
  final AddMenuSubcategoryUseCase addSubcategoryUseCase;
  final UpdateMenuSubcategoryUseCase updateSubcategoryUseCase;
  final DeleteMenuSubcategoryUseCase deleteSubcategoryUseCase;
  final UpdateMenuSubcategoryPositionsUseCase updateSubcategoryPositionsUseCase;

  // Cached full list so search can filter without reloading from DB
  List<MenuSubcategory> _allSubcategories = [];
  List<MenuSubcategory> get allSubcategories => _allSubcategories;

  MenuSubcategoryBloc({
    required this.getSubcategoriesUseCase,
    required this.getSubcategoriesByCategoryUseCase,
    required this.addSubcategoryUseCase,
    required this.updateSubcategoryUseCase,
    required this.deleteSubcategoryUseCase,
    required this.updateSubcategoryPositionsUseCase,
  }) : super(MenuSubcategoryInitial()) {
    on<LoadMenuSubcategories>(_onLoadMenuSubcategories);
    on<LoadMenuSubcategoriesByCategory>(_onLoadMenuSubcategoriesByCategory);
    on<AddMenuSubcategory>(_onAddMenuSubcategory);
    on<UpdateMenuSubcategory>(_onUpdateMenuSubcategory);
    on<DeleteMenuSubcategory>(_onDeleteMenuSubcategory);
    on<ReorderMenuSubcategories>(_onReorderMenuSubcategories);
    on<ToggleSubcategoryReorderMode>(_onToggleReorderMode);
    on<SaveSubcategoryReorder>(_onSaveSubcategoryReorder);
    on<CancelSubcategoryReorder>(_onCancelSubcategoryReorder);
    on<SearchMenuSubcategories>(_onSearchMenuSubcategories);
  }

  Future<void> _onLoadMenuSubcategories(
    LoadMenuSubcategories event,
    Emitter<MenuSubcategoryState> emit,
  ) async {
    emit(MenuSubcategoryLoading());
    try {
      final subcategories = await getSubcategoriesUseCase();
      shared.SuspensionUtil.sortListBySuspensionTag(subcategories);
      shared.SuspensionUtil.setShowSuspensionStatus(subcategories);
      _allSubcategories = subcategories;
      emit(
        MenuSubcategoryLoaded(
          subcategories: subcategories,
          isSearchActive: false,
        ),
      );
      event.onSuccess?.call();
    } catch (e) {
      event.onError?.call(e.toString());
      emit(MenuSubcategoryError(e.toString()));
    }
  }

  Future<void> _onLoadMenuSubcategoriesByCategory(
    LoadMenuSubcategoriesByCategory event,
    Emitter<MenuSubcategoryState> emit,
  ) async {
    emit(MenuSubcategoryLoading());
    try {
      final subcategories = await getSubcategoriesByCategoryUseCase(
        event.categoryId,
      );
      final allSubcategories = await getSubcategoriesUseCase();
      _allSubcategories = allSubcategories;
      emit(
        MenuSubcategoryLoaded(
          subcategories: subcategories,
          categoryIdFilter: event.categoryId,
          isSearchActive: false,
        ),
      );
      event.onSuccess?.call();
    } catch (e) {
      event.onError?.call(e.toString());
      emit(MenuSubcategoryError(e.toString()));
    }
  }

  Future<void> _onAddMenuSubcategory(
    AddMenuSubcategory event,
    Emitter<MenuSubcategoryState> emit,
  ) async {
    try {
      await addSubcategoryUseCase(event.subcategory);
      event.onSuccess?.call();
      _reload(emit);
    } catch (e) {
      event.onError?.call(e.toString());
      emit(MenuSubcategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateMenuSubcategory(
    UpdateMenuSubcategory event,
    Emitter<MenuSubcategoryState> emit,
  ) async {
    try {
      await updateSubcategoryUseCase(event.subcategory);
      event.onSuccess?.call();

      // Update cached _allSubcategories
      final allIndex = _allSubcategories.indexWhere(
        (sub) => sub.id == event.subcategory.id,
      );
      if (allIndex != -1) {
        _allSubcategories[allIndex] = event.subcategory;
      }

      if (state is MenuSubcategoryLoaded) {
        final currentState = state as MenuSubcategoryLoaded;
        final list = List<MenuSubcategory>.from(currentState.subcategories);
        final index = list.indexWhere((sub) => sub.id == event.subcategory.id);
        if (index != -1) {
          list[index] = event.subcategory;
          emit(currentState.copyWith(subcategories: list));
        }
      }
    } catch (e) {
      event.onError?.call(e.toString());
      emit(MenuSubcategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteMenuSubcategory(
    DeleteMenuSubcategory event,
    Emitter<MenuSubcategoryState> emit,
  ) async {
    try {
      // Find deleted subcategory to identify its categoryId
      final targetIndex = _allSubcategories.indexWhere(
        (sub) => sub.id == event.id,
      );
      final int? categoryId = targetIndex != -1
          ? _allSubcategories[targetIndex].categoryId
          : null;

      await deleteSubcategoryUseCase(event.id);
      event.onSuccess?.call();

      // Remove from cached _allSubcategories
      _allSubcategories.removeWhere((sub) => sub.id == event.id);

      if (state is MenuSubcategoryLoaded) {
        final currentState = state as MenuSubcategoryLoaded;
        final list = List<MenuSubcategory>.from(currentState.subcategories);
        list.removeWhere((sub) => sub.id == event.id);

        // Re-index position indices for remaining items in this category
        if (categoryId != null) {
          final categoryItems = _allSubcategories
              .where((sub) => sub.categoryId == categoryId)
              .toList();
          final updatedPositionsList = <MenuSubcategory>[];
          for (int i = 0; i < categoryItems.length; i++) {
            final updatedItem = categoryItems[i].copyWith(position: i);
            updatedPositionsList.add(updatedItem);

            // Update in _allSubcategories
            final idx = _allSubcategories.indexWhere(
              (sub) => sub.id == updatedItem.id,
            );
            if (idx != -1) _allSubcategories[idx] = updatedItem;

            // Update in current state list
            final stateIdx = list.indexWhere((sub) => sub.id == updatedItem.id);
            if (stateIdx != -1) list[stateIdx] = updatedItem;
          }

          // Persist updated positions in database asynchronously
          updateSubcategoryPositionsUseCase(updatedPositionsList);
        }

        emit(currentState.copyWith(subcategories: list));
      }
    } catch (e) {
      event.onError?.call(e.toString());
      emit(MenuSubcategoryError(e.toString()));
    }
  }

  Future<void> _onReorderMenuSubcategories(
    ReorderMenuSubcategories event,
    Emitter<MenuSubcategoryState> emit,
  ) async {
    if (state is MenuSubcategoryLoaded) {
      final currentState = state as MenuSubcategoryLoaded;

      final int oldIndex = event.oldIndex;
      final int newIndex = event.newIndex;

      final currentList = List<MenuSubcategory>.from(
        currentState.subcategories,
      );
      if (oldIndex < 0 || oldIndex >= currentList.length) return;
      if (newIndex < 0 || newIndex > currentList.length) return;

      final item = currentList.removeAt(oldIndex);
      // onReorderItem automatically pre-adjusts newIndex for the removed item
      final int insertIndex = newIndex.clamp(0, currentList.length);
      currentList.insert(insertIndex, item);

      emit(currentState.copyWith(subcategories: currentList));
    }
  }

  void _onToggleReorderMode(
    ToggleSubcategoryReorderMode event,
    Emitter<MenuSubcategoryState> emit,
  ) {
    if (state is MenuSubcategoryLoaded) {
      final currentState = state as MenuSubcategoryLoaded;
      final bool wasReordering = currentState.isReorderAllowed;
      final bool enteringReorder = !wasReordering;

      emit(
        currentState.copyWith(
          isReorderAllowed: enteringReorder,
          initialSubcategories: enteringReorder
              ? List<MenuSubcategory>.from(currentState.subcategories)
              : null,
        ),
      );
      event.onSuccess?.call();
    }
  }

  Future<void> _onSaveSubcategoryReorder(
    SaveSubcategoryReorder event,
    Emitter<MenuSubcategoryState> emit,
  ) async {
    if (state is MenuSubcategoryLoaded) {
      final currentState = state as MenuSubcategoryLoaded;
      try {
        final currentList = currentState.subcategories;
        final initialList = currentState.initialSubcategories;

        final updatedPositionsList = <MenuSubcategory>[];
        for (int i = 0; i < currentList.length; i++) {
          final updated = currentList[i].copyWith(position: i);
          updatedPositionsList.add(updated);
        }

        // Compare position changes with original list to determine if update is needed
        bool hasPositionChanged = false;
        if (initialList == null || initialList.length != currentList.length) {
          hasPositionChanged = true;
        } else {
          for (int i = 0; i < currentList.length; i++) {
            if (currentList[i].id != initialList[i].id) {
              hasPositionChanged = true;
              break;
            }
          }
        }

        if (hasPositionChanged) {
          for (final updated in updatedPositionsList) {
            final masterIdx = _allSubcategories.indexWhere(
              (s) => s.id == updated.id,
            );
            if (masterIdx != -1) {
              _allSubcategories[masterIdx] = updated;
            }
          }
          await updateSubcategoryPositionsUseCase(updatedPositionsList);
        }

        emit(
          currentState.copyWith(
            subcategories: updatedPositionsList,
            initialSubcategories: null,
            isReorderAllowed: false,
          ),
        );
        event.onSuccess?.call();
      } catch (e) {
        event.onError?.call(e.toString());
        emit(MenuSubcategoryError(e.toString()));
      }
    }
  }

  Future<void> _onCancelSubcategoryReorder(
    CancelSubcategoryReorder event,
    Emitter<MenuSubcategoryState> emit,
  ) async {
    if (state is MenuSubcategoryLoaded) {
      final currentState = state as MenuSubcategoryLoaded;
      final initialList = currentState.initialSubcategories;

      if (initialList != null) {
        // Restore initial subcategories list without hitting database
        for (final item in initialList) {
          final masterIdx = _allSubcategories.indexWhere(
            (s) => s.id == item.id,
          );
          if (masterIdx != -1) {
            _allSubcategories[masterIdx] = item;
          }
        }

        emit(
          currentState.copyWith(
            subcategories: List<MenuSubcategory>.from(initialList),
            initialSubcategories: null,
            isReorderAllowed: false,
          ),
        );
        event.onSuccess?.call();
      } else {
        final categoryId = currentState.categoryIdFilter;
        emit(MenuSubcategoryLoading());
        try {
          final subcategories = categoryId == null
              ? await getSubcategoriesUseCase()
              : await getSubcategoriesByCategoryUseCase(categoryId);
          _allSubcategories = subcategories;
          emit(
            MenuSubcategoryLoaded(
              subcategories: subcategories,
              categoryIdFilter: categoryId,
              isReorderAllowed: false,
              isSearchActive: false,
            ),
          );
          event.onSuccess?.call();
        } catch (e) {
          event.onError?.call(e.toString());
          emit(MenuSubcategoryError(e.toString()));
        }
      }
    }
  }

  void _reload(Emitter<MenuSubcategoryState> emit) {
    if (state is MenuSubcategoryLoaded) {
      final categoryId = (state as MenuSubcategoryLoaded).categoryIdFilter;
      if (categoryId != null) {
        add(LoadMenuSubcategoriesByCategory(categoryId));
        return;
      }
    }
    add(LoadMenuSubcategories());
  }

  void _onSearchMenuSubcategories(
    SearchMenuSubcategories event,
    Emitter<MenuSubcategoryState> emit,
  ) {
    final query = event.query.trim().toLowerCase();
    final bool isSearchActive = query.isNotEmpty;

    final filtered = isSearchActive
        ? _allSubcategories
              .where((sub) => sub.name?.toLowerCase().contains(query) ?? false)
              .toList()
        : List<MenuSubcategory>.from(_allSubcategories);

    // Always re-sort and re-stamp so letter headers are correct
    // regardless of whether the user is browsing or searching.
    shared.SuspensionUtil.sortListBySuspensionTag(filtered);
    shared.SuspensionUtil.setShowSuspensionStatus(filtered);

    if (state is MenuSubcategoryLoaded) {
      final current = state as MenuSubcategoryLoaded;
      emit(
        current.copyWith(
          subcategories: filtered,
          isSearchActive: isSearchActive,
        ),
      );
    } else {
      emit(
        MenuSubcategoryLoaded(
          subcategories: filtered,
          isSearchActive: isSearchActive,
        ),
      );
    }
  }
}

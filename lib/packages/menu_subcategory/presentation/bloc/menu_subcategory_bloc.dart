import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/menu_subcategory.dart';
import '../../domain/usecases/menu_subcategory_usecases.dart';
import 'menu_subcategory_event.dart';
import 'menu_subcategory_state.dart';

class MenuSubcategoryBloc
    extends Bloc<MenuSubcategoryEvent, MenuSubcategoryState> {
  final GetMenuSubcategoriesUseCase getSubcategoriesUseCase;
  final GetMenuSubcategoriesByCategoryUseCase getSubcategoriesByCategoryUseCase;
  final AddMenuSubcategoryUseCase addSubcategoryUseCase;
  final UpdateMenuSubcategoryUseCase updateSubcategoryUseCase;
  final DeleteMenuSubcategoryUseCase deleteSubcategoryUseCase;
  final UpdateMenuSubcategoryPositionsUseCase updateSubcategoryPositionsUseCase;

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
  }

  Future<void> _onLoadMenuSubcategories(
    LoadMenuSubcategories event,
    Emitter<MenuSubcategoryState> emit,
  ) async {
    emit(MenuSubcategoryLoading());
    try {
      final subcategories = await getSubcategoriesUseCase();
      emit(MenuSubcategoryLoaded(subcategories: subcategories));
    } catch (e) {
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
      emit(
        MenuSubcategoryLoaded(
          subcategories: subcategories,
          categoryIdFilter: event.categoryId,
        ),
      );
    } catch (e) {
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
      _reload(emit);
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
      await deleteSubcategoryUseCase(event.id);
      event.onSuccess?.call();
      _reload(emit);
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
      final subcategories = List<MenuSubcategory>.from(
        currentState.subcategories,
      );

      int oldIndex = event.oldIndex;
      int newIndex = event.newIndex;

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final item = subcategories.removeAt(oldIndex);
      subcategories.insert(newIndex, item);

      emit(currentState.copyWith(subcategories: subcategories));

      final updatedSubcategories = <MenuSubcategory>[];
      for (int i = 0; i < subcategories.length; i++) {
        updatedSubcategories.add(subcategories[i].copyWith(position: i));
      }

      try {
        await updateSubcategoryPositionsUseCase(updatedSubcategories);
      } catch (e) {
        emit(MenuSubcategoryError('Failed to save order: $e'));
        _reload(emit);
      }
    }
  }

  void _onToggleReorderMode(
    ToggleSubcategoryReorderMode event,
    Emitter<MenuSubcategoryState> emit,
  ) {
    if (state is MenuSubcategoryLoaded) {
      final currentState = state as MenuSubcategoryLoaded;
      emit(
        currentState.copyWith(isReorderAllowed: !currentState.isReorderAllowed),
      );
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
}

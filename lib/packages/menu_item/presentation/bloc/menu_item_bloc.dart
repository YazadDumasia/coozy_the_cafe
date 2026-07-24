import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/menu_item_usecases.dart';
import 'menu_item_event.dart';
import 'menu_item_state.dart';
import '../../../shared/l10n/locale_keys.dart';

class MenuItemBloc extends Bloc<MenuItemEvent, MenuItemState> {
  final GetMenuItemsUseCase getMenuItemsUseCase;
  final GetMenuItemsByCategoryUseCase getMenuItemsByCategoryUseCase;
  final GetMenuItemsBySubcategoryUseCase getMenuItemsBySubcategoryUseCase;
  final AddMenuItemUseCase addMenuItemUseCase;
  final UpdateMenuItemUseCase updateMenuItemUseCase;
  final DeleteMenuItemUseCase deleteMenuItemUseCase;

  MenuItemBloc({
    required this.getMenuItemsUseCase,
    required this.getMenuItemsByCategoryUseCase,
    required this.getMenuItemsBySubcategoryUseCase,
    required this.addMenuItemUseCase,
    required this.updateMenuItemUseCase,
    required this.deleteMenuItemUseCase,
  }) : super(MenuItemInitial()) {
    on<LoadMenuItems>(_onLoadMenuItems);
    on<LoadMenuItemsByCategory>(_onLoadMenuItemsByCategory);
    on<LoadMenuItemsBySubcategory>(_onLoadMenuItemsBySubcategory);
    on<AddMenuItem>(_onAddMenuItem);
    on<UpdateMenuItem>(_onUpdateMenuItem);
    on<DeleteMenuItem>(_onDeleteMenuItem);
  }

  Future<void> _onLoadMenuItems(
    LoadMenuItems event,
    Emitter<MenuItemState> emit,
  ) async {
    emit(MenuItemLoading());
    try {
      final items = await getMenuItemsUseCase();
      emit(MenuItemLoaded(items: items));
    } catch (e) {
      emit(MenuItemError(e.toString()));
    }
  }

  Future<void> _onLoadMenuItemsByCategory(
    LoadMenuItemsByCategory event,
    Emitter<MenuItemState> emit,
  ) async {
    emit(MenuItemLoading());
    try {
      final items = await getMenuItemsByCategoryUseCase(event.categoryId);
      emit(MenuItemLoaded(items: items, categoryIdFilter: event.categoryId));
    } catch (e) {
      emit(MenuItemError(e.toString()));
    }
  }

  Future<void> _onLoadMenuItemsBySubcategory(
    LoadMenuItemsBySubcategory event,
    Emitter<MenuItemState> emit,
  ) async {
    emit(MenuItemLoading());
    try {
      final items = await getMenuItemsBySubcategoryUseCase(event.subcategoryId);
      emit(
        MenuItemLoaded(items: items, subcategoryIdFilter: event.subcategoryId),
      );
    } catch (e) {
      emit(MenuItemError(e.toString()));
    }
  }

  Future<void> _onAddMenuItem(
    AddMenuItem event,
    Emitter<MenuItemState> emit,
  ) async {
    try {
      await addMenuItemUseCase(event.item);
      event.onSuccess?.call();
      _reload(emit);
    } catch (e) {
      event.onError?.call(LocaleKeys.crudErrorAdd);
      emit(MenuItemError(e.toString()));
    }
  }

  Future<void> _onUpdateMenuItem(
    UpdateMenuItem event,
    Emitter<MenuItemState> emit,
  ) async {
    try {
      await updateMenuItemUseCase(event.item);
      event.onSuccess?.call();
      _reload(emit);
    } catch (e) {
      event.onError?.call(LocaleKeys.crudErrorUpdate);
      emit(MenuItemError(e.toString()));
    }
  }

  Future<void> _onDeleteMenuItem(
    DeleteMenuItem event,
    Emitter<MenuItemState> emit,
  ) async {
    try {
      await deleteMenuItemUseCase(event.id);
      event.onSuccess?.call();
      _reload(emit);
    } catch (e) {
      event.onError?.call(LocaleKeys.crudErrorDelete);
      emit(MenuItemError(e.toString()));
    }
  }

  void _reload(Emitter<MenuItemState> emit) {
    if (state is MenuItemLoaded) {
      final s = state as MenuItemLoaded;
      if (s.subcategoryIdFilter != null) {
        add(LoadMenuItemsBySubcategory(s.subcategoryIdFilter!));
        return;
      }
      if (s.categoryIdFilter != null) {
        add(LoadMenuItemsByCategory(s.categoryIdFilter!));
        return;
      }
    }
    add(LoadMenuItems());
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';

import '../../domain/entities/menu_item.dart';
import '../../domain/services/menu_item_barcode_pdf_generator.dart';
import '../../domain/usecases/menu_item_usecases.dart';
import '../../../shared/l10n/locale_keys.dart';

part 'menu_item_event.dart';
part 'menu_item_state.dart';

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
    on<MenuItemBarcodePdfPrebuiltCompletedEvent>(
      _onMenuItemBarcodePdfPrebuiltCompleted,
    );
  }

  void _onMenuItemBarcodePdfPrebuiltCompleted(
    MenuItemBarcodePdfPrebuiltCompletedEvent event,
    Emitter<MenuItemState> emit,
  ) {
    if (state is MenuItemLoaded) {
      final current = state as MenuItemLoaded;
      emit(
        current.copyWith(
          prebuiltColumnsBarcodePdfBytes: event.prebuiltColumnsPdfBytes,
          isPrebuildingBarcodePdf: false,
        ),
      );
    }
  }

  void _triggerBackgroundBarcodePdfPrebuild() {
    Future(() async {
      try {
        final waiterRepo = core.sl<WaiterOrderPlacementRepository>();
        final catalogRes = await waiterRepo.getActiveMenuCatalog();

        List<MenuItemBarcodeInfo> barcodeItems = [];
        catalogRes.fold(
          (_) {},
          (catalog) => barcodeItems =
              MenuItemBarcodePdfGenerator.extractBarcodeItems(catalog),
        );

        if (barcodeItems.isEmpty) return;

        final Map<int, Uint8List> prebuiltCache = {};

        // 1. Prebuild 2 Columns first so default preview is ready
        final bytes2 = await MenuItemBarcodePdfGenerator.generatePdf(
          barcodeItems: barcodeItems,
          columnsCount: 2,
          title: 'Coozy The Cafe - Menu Item Barcodes',
        );
        prebuiltCache[2] = bytes2;
        add(
          MenuItemBarcodePdfPrebuiltCompletedEvent(
            prebuiltColumnsPdfBytes: Map<int, Uint8List>.from(prebuiltCache),
          ),
        );

        // 2. Prebuild 3 and 4 Columns in background so column switches are instant
        final otherColumns = [3, 4];
        for (final col in otherColumns) {
          final bytes = await MenuItemBarcodePdfGenerator.generatePdf(
            barcodeItems: barcodeItems,
            columnsCount: col,
            title: 'Coozy The Cafe - Menu Item Barcodes',
          );
          prebuiltCache[col] = bytes;
          add(
            MenuItemBarcodePdfPrebuiltCompletedEvent(
              prebuiltColumnsPdfBytes: Map<int, Uint8List>.from(prebuiltCache),
            ),
          );
        }
      } catch (e) {
        core.PlatformUtils.debugLog(
          MenuItemBloc,
          'Background prebuild Menu Item Barcode PDF failed: $e',
        );
      }
    });
  }

  Future<void> _onLoadMenuItems(
    LoadMenuItems event,
    Emitter<MenuItemState> emit,
  ) async {
    if (event.isSilent && state is MenuItemLoaded) {
      await _reloadSilently(emit);
      return;
    }
    emit(MenuItemLoading());
    try {
      final items = await getMenuItemsUseCase();
      emit(MenuItemLoaded(items: items, isPrebuildingBarcodePdf: true));
      if (items.isNotEmpty) {
        _triggerBackgroundBarcodePdfPrebuild();
      }
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
      await _reloadSilently(emit);
    } catch (e, stackTrace) {
      debugPrint('AddMenuItem Exception: $e\n$stackTrace');
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
      if (state is MenuItemLoaded) {
        final current = state as MenuItemLoaded;
        final updatedItems = current.items.map((item) {
          return item.id == event.item.id ? event.item : item;
        }).toList();
        emit(current.copyWith(items: updatedItems));
      } else {
        await _reloadSilently(emit);
      }
    } catch (e, stackTrace) {
      debugPrint('UpdateMenuItem Exception: $e\n$stackTrace');
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
      await _reloadSilently(emit);
    } catch (e, stackTrace) {
      debugPrint('DeleteMenuItem Exception: $e\n$stackTrace');
      event.onError?.call(LocaleKeys.crudErrorDelete);
      emit(MenuItemError(e.toString()));
    }
  }

  Future<void> _reloadSilently(Emitter<MenuItemState> emit) async {
    try {
      int? catId;
      int? subcatId;
      if (state is MenuItemLoaded) {
        final s = state as MenuItemLoaded;
        catId = s.categoryIdFilter;
        subcatId = s.subcategoryIdFilter;
      }

      List<MenuItem> items;
      if (subcatId != null) {
        items = await getMenuItemsBySubcategoryUseCase(subcatId);
      } else if (catId != null) {
        items = await getMenuItemsByCategoryUseCase(catId);
      } else {
        items = await getMenuItemsUseCase();
      }
      emit(
        MenuItemLoaded(
          items: items,
          categoryIdFilter: catId,
          subcategoryIdFilter: subcatId,
        ),
      );
    } catch (e) {
      emit(MenuItemError(e.toString()));
    }
  }
}

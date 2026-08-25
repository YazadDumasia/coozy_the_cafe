import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/menu_catalog_data.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/get_active_menu_catalog_usecase.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/get_order_details_usecase.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/submit_order_usecase.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/menu_item_picker_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class DummyRepository implements WaiterOrderPlacementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGetActiveMenuCatalogUseCase extends GetActiveMenuCatalogUseCase {
  final MenuCatalogData catalogData;
  FakeGetActiveMenuCatalogUseCase(this.catalogData) : super(DummyRepository());

  @override
  Future<Either<Failure, MenuCatalogData>> call() async {
    return Right(catalogData);
  }
}

class FakeSubmitOrderUseCase extends SubmitOrderUseCase {
  FakeSubmitOrderUseCase() : super(DummyRepository());
}

class FakeGetOrderDetailsUseCase extends GetOrderDetailsUseCase {
  FakeGetOrderDetailsUseCase() : super(DummyRepository());
}

void main() {
  group('MenuItemPickerBloc Search Tests', () {
    test(
      'updates searchQuery state when FilterSearchQueryEvent is added',
      () async {
        const emptyCatalog = MenuCatalogData(
          activeCategories: [],
          categoryDataList: [],
        );

        final bloc = MenuItemPickerBloc(
          getActiveMenuCatalogUseCase: FakeGetActiveMenuCatalogUseCase(
            emptyCatalog,
          ),
          submitOrderUseCase: FakeSubmitOrderUseCase(),
          getOrderDetailsUseCase: FakeGetOrderDetailsUseCase(),
        );

        bloc.add(const LoadMenuCatalogEvent());
        await pumpEventQueue();

        expect(bloc.state, isA<MenuItemPickerLoadedState>());
        expect((bloc.state as MenuItemPickerLoadedState).searchQuery, '');

        bloc.add(const FilterSearchQueryEvent('Pizza'));
        await pumpEventQueue();

        expect((bloc.state as MenuItemPickerLoadedState).searchQuery, 'Pizza');

        await bloc.close();
      },
    );
  });
}

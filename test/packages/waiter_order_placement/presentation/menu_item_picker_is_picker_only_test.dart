import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/menu_catalog_data.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_cart_item.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/get_active_menu_catalog_usecase.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/get_order_details_usecase.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/submit_order_usecase.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/menu_item_picker_bloc.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/pages/menu_item_picker/widget/current_order_tab_view.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

MenuItemPickerBloc createTestBloc() {
  return MenuItemPickerBloc(
    getActiveMenuCatalogUseCase: FakeGetActiveMenuCatalogUseCase(
      const MenuCatalogData(activeCategories: [], categoryDataList: []),
    ),
    submitOrderUseCase: SubmitOrderUseCase(DummyRepository()),
    getOrderDetailsUseCase: GetOrderDetailsUseCase(DummyRepository()),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CurrentOrderTabView isPickerOnly Tests', () {
    testWidgets('shows Submit button inplace of Bill Now when isPickerOnly is true', (tester) async {
      const sampleItem = OrderCartItem(
        menuItemId: 1,
        name: 'Cappuccino',
        price: 150.0,
        quantity: 2,
      );

      final bloc = createTestBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<MenuItemPickerBloc>.value(
              value: bloc,
              child: const CurrentOrderTabView(
                cartItems: [sampleItem],
                tableId: 1,
                tableName: 'Table 1',
                orderId: 101,
                isPickerOnly: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify "Submit" button is present and "Bill Now" / "Send Order" are NOT present
      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Bill Now'), findsNothing);
      expect(find.text('SEND ORDER'), findsNothing);

      await bloc.close();
    });

    testWidgets('shows Bill Now and Send Order when isPickerOnly is false and orderId != null', (tester) async {
      const sampleItem = OrderCartItem(
        menuItemId: 1,
        name: 'Espresso',
        price: 100.0,
        quantity: 1,
      );

      final bloc = createTestBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<MenuItemPickerBloc>.value(
              value: bloc,
              child: const CurrentOrderTabView(
                cartItems: [sampleItem],
                tableId: 1,
                tableName: 'Table 1',
                orderId: 101,
                isPickerOnly: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify Bill Now is present
      expect(find.text('Bill Now'), findsOneWidget);
      expect(find.text('Submit'), findsNothing);

      await bloc.close();
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';

void main() {
  group('MenuItemDetail DeepLink Route Tests', () {
    test('detailMenuItemScreenRoute should have correct sub-route pattern', () {
      expect(AppRoutePath.detailMenuItemScreenRoute, equals('detail/:id'));
    });

    test('menuItemDetail route name should be menu-item-detail', () {
      expect(AppRouteName.menuItemDetail, equals('menu-item-detail'));
    });
  });
}

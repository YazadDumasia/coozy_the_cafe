import 'package:coozy_the_cafe/packages/auth/coozy_auth.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';

import 'package:coozy_the_cafe/packages/home_page/home_injection.dart';

import 'package:coozy_the_cafe/packages/table_management/table_injection.dart';
import 'package:coozy_the_cafe/packages/menu_category/menu_category_injection.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/menu_subcategory_injection.dart';
import 'package:coozy_the_cafe/packages/menu_item/menu_item_injection.dart';
import 'package:coozy_the_cafe/packages/inventory/inventory_injection.dart';
import 'package:coozy_the_cafe/packages/purchase/purchase_injection.dart';
import 'package:coozy_the_cafe/packages/customer/customer_injection.dart';
import 'package:coozy_the_cafe/packages/recipes/recipes_injection.dart';
import 'package:coozy_the_cafe/packages/reservation/reservation_injection.dart';
import 'package:coozy_the_cafe/packages/staff_management/staff_management_injection.dart';
import 'package:coozy_the_cafe/packages/settings/settings_injection.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/waiter_order_placement.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/kitchen_management.dart';

Future<void> initDI() async {
  // Auth Package Dependencies
  registerAuthDependencies(sl);

  // Home Package Dependencies
  registerHomeDependencies(sl);

  // Table Info Package Dependencies
  registerTableDependencies(sl);

  // Menu Category Package Dependencies
  registerMenuCategoryDependencies(sl);

  // Menu Subcategory Package Dependencies
  registerMenuSubcategoryDependencies(sl);

  // Menu Item Package Dependencies
  registerMenuItemDependencies(sl);

  // Inventory Package Dependencies
  registerInventoryDependencies(sl);
  registerPurchaseDependencies(sl);
  registerCustomerDependencies(sl);
  registerRecipesDependencies(sl);

  // Reservation Package Dependencies
  registerReservationDependencies(sl);

  // Staff Management Package Dependencies
  registerStaffManagementDependencies(sl);

  // Settings Package Dependencies
  registerSettingsDependencies(sl);

  // Waiter Order Placement Dependencies
  registerWaiterOrderPlacementDependencies(sl);

  // Kitchen Management Dependencies
  registerKitchenManagementDependencies(sl);
}


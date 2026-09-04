class AppRoutePath {
  // HomeScreen
  static const String homeRoute = '/';
  static const String licenseRoute = '/license';

  // Initial Screen
  static const String splashRoute = '/splash';

  // Authentication Screens
  static const String loginRoute = '/login';
  static const String registrationRoute = '/register';
  static const String loginViaPhoneNumberRoute = '/login_via_phone';
  static const String otpScreenRoute = '/otp';
  static const String otpVerificationRoute = '/otp-verification';
  static const String successfullyScreenRoute = '/successfully';
  static const String businessOnboardingRoute = '/business-onboarding';

  // Bottom Nav Main Route
  static const String homeScreenRoute = '/home';

  // Drawer Screens / Top-level
  static const String tableInfoScreenRoute = '/table-info';
  static const String tablePickerScreenRoute = '/table-picker';
  static const String menuItemFullListScreenRoute = '/menu-items';
  static const String menuCategoryFullListRoute = '/menu-categories';
  static const String menuSubCategoryFullListRoute = '/menu-subcategories';
  static const String recipesListScreenRoute = '/recipes';
  static const String inventoryListScreenRoute = '/inventory';
  static const String purchaseListScreenRoute = '/purchases';
  static const String reservationListScreenRoute = '/reservations';
  static const String customerListScreenRoute = '/customers';
  static const String orderListScreenRoute = '/orders';
  static const String invoiceListScreenRoute = '/invoices';
  static const String invoicePaymentListScreenRoute = '/invoice-payments';
  static const String invoicePaymentMethodListScreenRoute =
      '/invoice-payment-methods';
  static const String expenditureListScreenRoute = '/expenditures';
  static const String reportScreenRoute = '/reports';
  static const String staffManagementScreenRoute = '/staff';
  static const String settingsScreenRoute = '/settings';
  static const String currencyExchangeScreenRoute = '/settings/currency-exchange';
  static const String waiterOrderPlacementScreenRoute =
      '/waiter-order-placement';
  static const String kitchenScreenRoute = '/kitchen';
  static const String checkoutScreenRoute = '/checkout';


  // Sub-routes for Table Info (Nested under Home -> Table Info)
  static const String addNewTableInfoScreenRoute = 'table-add';
  static const String updateTableInfoScreenRoute = 'table-update';

  // Sub-routes for Menu Items
  static const String addNewMenuItemScreenRoute = 'menu-item-add';
  static const String updateMenuItemScreenRoute = 'menu-item-update';
  static const String detailMenuItemScreenRoute = 'detail/:id';
  static String menuItemDetailRoute(dynamic id) =>
      '$menuItemFullListScreenRoute/detail/$id';

  // Sub-routes for Menu Categories
  static const String addNewMenuCategoryScreenRoute = 'menu-category-add';
  static const String updateMenuCategoryScreenRoute = 'menu-category-update';

  // Sub-routes for Menu Sub Categories
  static const String addNewMenuSubCategoryScreenRoute = 'add-subcategory';
  static const String updateMenuSubCategoryScreenRoute = 'update-subcategory';

  // Sub-routes for Inventory
  static const String addNewInventoryScreenRoute = 'inventory-add';
  static const String updateInventoryScreenRoute = 'inventory-update/:id';
  static const String addPurchaseScreenRoute = '/add-purchase/:id';
  static const String inventoryAddOrEditItemRoute = 'inventory-edit';
  static const String inventoryPickerPageRoute = 'inventory-picker';

  // Sub-routes for Purchases
  static const String purchaseAddOrEditItemRoute = 'purchase-edit';
  static const String purchasePickerPageRoute = 'purchase-picker';

  // Sub-routes for Reservations
  static const String reservationAddOrEditItemRoute = 'reservation-edit';
  static const String reservationPickerPageRoute = 'reservation-picker';

  // Sub-routes for Recipes
  static const String recipesInfoScreenRoute = 'recipe-info';
  static const String recipesBookmarkListScreenRoute = 'recipe-bookmarks';
  static const String recipesAddOrEditScreenRoute = 'recipe-edit';

  // Sub-routes for Orders
  static const String orderInfoScreenRoute = 'info/:id';
  static String orderInfoRoute(dynamic id) =>
      '$orderListScreenRoute/info/$id';
  static const String orderPickerPageRoute = 'order-picker';
  static const String orderStatusUpdateScreenRoute = 'order-status-update';


  // Sub-routes for Invoices
  static const String invoiceInfoScreenRoute = 'invoice-info';
  static const String invoicePickerPageRoute = 'invoice-picker';
  static const String invoiceStatusUpdateScreenRoute = 'invoice-status-update';
  static const String invoiceAddOrEditScreenRoute = 'invoice-edit';

  // Sub-routes for Invoice Payments
  static const String invoicePaymentScreenRoute = 'payment';
  static const String invoicePaymentInfoScreenRoute = 'info';
  static const String invoicePaymentAddOrEditScreenRoute = 'edit';
  static const String invoicePaymentStatusUpdateScreenRoute = 'status-update';
  static const String invoicePaymentPickerPageRoute = 'picker';

  // Sub-routes for Invoice Payment Methods
  static const String addOrEditInvoicePaymentMethodScreenRoute = 'edit';
  static const String invoicePaymentMethodInfoScreenRoute = 'info';
  static const String invoicePaymentMethodPickerPageRoute = 'picker';
  static const String invoicePaymentMethodStatusUpdateScreenRoute =
      'status-update';
  static const String invoicePaymentMethodDeleteScreenRoute = 'delete';
  static const String invoicePaymentMethodRestoreScreenRoute = 'restore';
  static const String invoicePaymentMethodArchiveScreenRoute = 'archive';
  static const String invoicePaymentMethodUnarchiveScreenRoute = 'unarchive';
  static const String invoicePaymentMethodTrashScreenRoute = 'trash';
  static const String invoicePaymentMethodUntrashScreenRoute = 'untrash';
  static const String invoicePaymentMethodDeleteConfirmationScreenRoute =
      'delete-confirm';
  static const String invoicePaymentMethodRestoreConfirmationScreenRoute =
      'restore-confirm';
  static const String invoicePaymentMethodArchiveConfirmationScreenRoute =
      'archive-confirm';
  static const String invoicePaymentMethodUnarchiveConfirmationScreenRoute =
      'unarchive-confirm';
  static const String invoicePaymentMethodTrashConfirmationScreenRoute =
      'trash-confirm';
  static const String invoicePaymentMethodUntrashConfirmationScreenRoute =
      'untrash-confirm';
  static const String invoicePaymentMethodDeleteSuccessScreenRoute =
      'delete-success';
  static const String invoicePaymentMethodRestoreSuccessScreenRoute =
      'restore-success';
  static const String invoicePaymentMethodArchiveSuccessScreenRoute =
      'archive-success';
  static const String invoicePaymentMethodUnarchiveSuccessScreenRoute =
      'unarchive-success';
  static const String invoicePaymentMethodTrashSuccessScreenRoute =
      'trash-success';
  static const String invoicePaymentMethodUntrashSuccessScreenRoute =
      'untrash-success';
  static const String invoicePaymentMethodDeleteFailureScreenRoute =
      'delete-failure';
  static const String invoicePaymentMethodRestoreFailureScreenRoute =
      'restore-failure';
  static const String invoicePaymentMethodArchiveFailureScreenRoute =
      'archive-failure';
  static const String invoicePaymentMethodUnarchiveFailureScreenRoute =
      'unarchive-failure';
  static const String invoicePaymentMethodTrashFailureScreenRoute =
      'trash-failure';
  static const String invoicePaymentMethodUntrashFailureScreenRoute =
      'untrash-failure';
  static const String invoicePaymentMethodStatusUpdateSuccessScreenRoute =
      'status-success';
  static const String invoicePaymentMethodStatusUpdateFailureScreenRoute =
      'status-failure';
  static const String invoicePaymentMethodStatusUpdateConfirmationScreenRoute =
      'status-confirm';
  static const String
  invoicePaymentMethodStatusUpdateSuccessConfirmationScreenRoute =
      'status-success-confirm';
  static const String
  invoicePaymentMethodStatusUpdateFailureConfirmationScreenRoute =
      'status-failure-confirm';

  // Sub-routes for Reports
  static const String reportDetailScreenRoute = 'detail';
  static const String reportFilterScreenRoute = 'filter';
  static const String reportPickerPageRoute = 'picker';
  static const String reportInfoScreenRoute = 'info';

  // Sub-routes for Expenditures
  static const String expenditureAddOrEditScreenRoute = 'edit';
  static const String expenditureInfoScreenRoute = 'info';

  // Sub-routes for Staff Management
  static const String employeeListScreenRoute = 'employees';
  static const String employeeAttendanceScreenRoute = 'attendance';
  static const String employeeLeaveScreenRoute = 'leave';
  static const String employeesReportsScreenRoute = 'employees-reports';
  static const String employeeInfoScreenRoute = 'employee-info';
  static const String addOrEditEmployeeScreenRoute = 'edit-employee';
  static const String employeeAttendanceInfoScreenRoute = 'attendance-info';
  static const String addOrEditEmployeeAttendanceScreenRoute =
      'edit-attendance';
  static const String employeeLeaveInfoScreenRoute = 'leave-info';
  static const String addOrEditEmployeeLeaveScreenRoute = 'edit-leave';

  // Sub-routes for Customers
  static const String customerInfoScreenRoute = 'customer-info';
  static const String addOrEditCustomerScreenRoute = 'customer-edit';
  static const String customerPickerPageRoute = 'customer-picker';
}

class AppRouteName {
  static const String home = 'home';
  static const String license = 'license';
  static const String splash = 'splash';
  static const String login = 'login';
  static const String registration = 'registration';
  static const String loginViaPhone = 'login-via-phone';
  static const String otp = 'otp';
  static const String otpVerification = 'otp-verification';
  static const String successfully = 'successfully';
  static const String businessOnboarding = 'business-onboarding';
  static const String mainHome = 'main-home';

  static const String inventoryList = 'inventory-list';
  static const String inventoryAdd = 'inventory-add';
  static const String inventoryUpdate = 'inventory-update';
  static const String inventoryPicker = 'inventory-picker';

  static const String purchaseList = 'purchase-list';
  static const String addPurchase = 'add-purchase';
  static const String purchasePicker = 'purchase-picker';

  static const String tableInfoList = 'table-info-list';
  static const String tablePicker = 'table-picker';
  static const String tableInfoAdd = 'table-info-add';
  static const String tableInfoUpdate = 'table-info-update';

  static const String menuItemList = 'menu-item-list';
  static const String menuItemAdd = 'menu-item-add';
  static const String menuItemUpdate = 'menu-item-update';
  static const String menuItemDetail = 'menu-item-detail';

  static const String menuCategoryList = 'menu-category-list';
  static const String menuCategoryAdd = 'menu-category-add';
  static const String menuCategoryUpdate = 'menu-category-update';

  static const String menuSubCategoryList = 'menu-subcategory-list';
  static const String menuSubCategoryAdd = 'menu-subcategory-add';
  static const String menuSubCategoryUpdate = 'menu-subcategory-update';

  static const String recipesList = 'recipes-list';
  static const String recipesBookmarkList = 'recipes-bookmark-list';
  static const String recipesInfo = 'recipes-info';
  static const String recipesAddOrEdit = 'recipes-add-or-edit';

  static const String staffManagement = 'staff-management';
  static const String employeeList = 'employee-list';
  static const String employeeAttendance = 'employee-attendance';
  static const String employeeLeave = 'employee-leave';
  static const String employeesReports = 'employees-reports';

  static const String customerList = 'customer-list';
  static const String customerInfo = 'customer-info';
  static const String customerEdit = 'customer-edit';
  static const String customerPicker = 'customer-picker';

  static const String reservationList = 'reservation-list';

  static const String settings = 'settings';
  static const String currencyExchange = 'currency-exchange';
  static const String kitchen = 'kitchen';
  static const String orders = 'orders';

  static String getTitleForRouteName(String? name) {
    switch (name) {
      case orders:
        return 'Orders';
      case kitchen:
        return 'Kitchen Display';

      case home:
      case mainHome:
        return 'Home';
      case splash:
        return 'Splash';
      case login:
        return 'Login';
      case registration:
        return 'Registration';
      case loginViaPhone:
        return 'Login via Phone';
      case otp:
      case otpVerification:
        return 'OTP Verification';
      case successfully:
        return 'Success';
      case businessOnboarding:
        return 'Business Onboarding';
      case inventoryList:
        return 'Inventory';
      case inventoryAdd:
        return 'Add Inventory';
      case inventoryUpdate:
        return 'Update Inventory';
      case inventoryPicker:
        return 'Inventory Picker';
      case purchaseList:
        return 'Purchases';
      case addPurchase:
        return 'Add Purchase';
      case purchasePicker:
        return 'Purchase Picker';
      case tableInfoList:
        return 'Tables';
      case tablePicker:
        return 'Table Picker';
      case tableInfoAdd:
        return 'Add Table';
      case tableInfoUpdate:
        return 'Update Table';
      case menuItemList:
        return 'Menu Items';
      case menuItemAdd:
        return 'Add Menu Item';
      case menuItemUpdate:
        return 'Update Menu Item';
      case menuCategoryList:
        return 'Menu Categories';
      case menuCategoryAdd:
        return 'Add Category';
      case menuCategoryUpdate:
        return 'Update Category';
      case menuSubCategoryList:
        return 'Menu Subcategories';
      case menuSubCategoryAdd:
        return 'Add Subcategory';
      case menuSubCategoryUpdate:
        return 'Update Subcategory';
      case recipesList:
        return 'Recipes';
      case recipesBookmarkList:
        return 'Bookmarked Recipes';
      case recipesInfo:
        return 'Recipe Info';
      case recipesAddOrEdit:
        return 'Edit Recipe';
      case staffManagement:
      case employeeList:
        return 'Staff Management';
      case employeeAttendance:
        return 'Staff Attendance';
      case employeeLeave:
        return 'Staff Leave';
      case employeesReports:
        return 'Staff Reports';
      case customerList:
        return 'Customers';
      case reservationList:
        return 'Reservations';
      case customerInfo:
        return 'Customer Info';
      case customerEdit:
        return 'Edit Customer';
      case customerPicker:
        return 'Customer Picker';
      case settings:
        return 'Settings';
      default:
        return 'Coozy the Cafe';
    }
  }
}

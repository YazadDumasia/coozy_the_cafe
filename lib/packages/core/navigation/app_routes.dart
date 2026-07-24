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

  // Sub-routes for Table Info (Nested under Home -> Table Info)
  static const String addNewTableInfoScreenRoute = 'add';
  static const String updateTableInfoScreenRoute = 'update';

  // Sub-routes for Menu Items
  static const String addNewMenuItemScreenRoute = 'add';
  static const String updateMenuItemScreenRoute = 'update';

  // Sub-routes for Menu Categories
  static const String addNewMenuCategoryScreenRoute = 'add';
  static const String updateMenuCategoryScreenRoute = 'update';

  // Sub-routes for Menu Sub Categories
  static const String addNewMenuSubCategoryScreenRoute = 'add-subcategory';
  static const String updateMenuSubCategoryScreenRoute = 'update-subcategory';

  // Sub-routes for Inventory
  static const String addNewInventoryScreenRoute = 'add';
  static const String updateInventoryScreenRoute = 'update/:id';
  static const String addPurchaseScreenRoute = 'add-purchase/:id';
  static const String inventoryAddOrEditItemRoute = 'edit';
  static const String inventoryPickerPageRoute = 'picker';

  // Sub-routes for Purchases
  static const String purchaseAddOrEditItemRoute = 'edit';
  static const String purchasePickerPageRoute = 'picker';

  // Sub-routes for Reservations
  static const String reservationAddOrEditItemRoute = 'edit';
  static const String reservationPickerPageRoute = 'picker';

  // Sub-routes for Recipes
  static const String recipesInfoScreenRoute = 'info';
  static const String recipesBookmarkListScreenRoute = 'bookmarks';
  static const String recipesAddOrEditScreenRoute = 'edit';

  // Sub-routes for Orders
  static const String orderInfoScreenRoute = 'info';
  static const String orderPickerPageRoute = 'picker';
  static const String orderStatusUpdateScreenRoute = 'status-update';

  // Sub-routes for Invoices
  static const String invoiceInfoScreenRoute = 'info';
  static const String invoicePickerPageRoute = 'picker';
  static const String invoiceStatusUpdateScreenRoute = 'status-update';
  static const String invoiceAddOrEditScreenRoute = 'edit';

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
  static const String customerInfoScreenRoute = 'info';
  static const String addOrEditCustomerScreenRoute = 'edit';
  static const String customerPickerPageRoute = 'picker';
}

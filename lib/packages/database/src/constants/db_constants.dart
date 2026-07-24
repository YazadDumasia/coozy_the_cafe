class DbConstants {
  DbConstants._();

  static const String fullBackupPrefix = 'coozy_full_backup';
  static const String dailyBackupPrefix = 'coozy_daily_backup';
  static const String weeklyBackupPrefix = 'coozy_weekly_backup';

  // ---- PERMISSIONS ----
  static const String permissionManageMenu = 'manage_menu';
  static const String permissionTakeOrders = 'take_orders';
  static const String permissionKitchenView = 'kitchen_view';
  static const String permissionBilling = 'billing';
  static const String permissionManageInventory = 'manage_inventory';
  static const String permissionManageEmployees = 'manage_employees';
  static const String permissionManageReservations = 'manage_reservations';
  static const String permissionViewReports = 'view_reports';
  static const String permissionAdminSettings = 'admin_settings';

  static const List<String> allPermissions = [
    permissionManageMenu,
    permissionTakeOrders,
    permissionKitchenView,
    permissionBilling,
    permissionManageInventory,
    permissionManageEmployees,
    permissionManageReservations,
    permissionViewReports,
    permissionAdminSettings,
  ];
}

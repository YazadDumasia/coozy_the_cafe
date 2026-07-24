/// Application-wide constants and utility methods.
class AppConstants {
  AppConstants._();

  /// Application name.
  static const String appName = 'Coozy The Cafe';

  /// Database configuration.
  static const String databaseName = 'coozy_the_cafe';
  static const int databaseVersion = 1;
  static const String secretKey = 'CoozyTheCafe';

  /// Backup file prefixes.
  static const String dailyBackupPrefix = 'coozy_daily_orders_invoices';
  static const String weeklyBackupPrefix = 'coozy_weekly_orders_invoices';
  static const String fullBackupPrefix = 'coozy_backup';

  /// Pagination defaults.
  static const int defaultPageSize = 20;
  static const int defaultBatchSize = 200;
}

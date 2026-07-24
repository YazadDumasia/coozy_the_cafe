/// Base exception for database operations.
class DatabaseException implements Exception {
  final String message;
  const DatabaseException({required this.message});

  @override
  String toString() => 'DatabaseException: $message';
}

/// Exception for cache operations.
class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Exception for backup/restore operations.
class BackupException implements Exception {
  final String message;
  const BackupException({required this.message});

  @override
  String toString() => 'BackupException: $message';
}

/// Exception for encryption/decryption operations.
class EncryptionException implements Exception {
  final String message;
  const EncryptionException({required this.message});

  @override
  String toString() => 'EncryptionException: $message';
}

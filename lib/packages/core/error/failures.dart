import 'package:equatable/equatable.dart';

/// Base class for all application failures.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure originating from the local database.
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.statusCode});
}

/// Failure originating from cache operations.
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode});
}

/// Failure originating from backup/restore operations.
class BackupFailure extends Failure {
  const BackupFailure({required super.message, super.statusCode});
}

/// Failure originating from encryption/decryption operations.
class EncryptionFailure extends Failure {
  const EncryptionFailure({required super.message, super.statusCode});
}

/// Failure originating from permission issues.
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.statusCode});
}

/// Generic unexpected failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.statusCode});
}

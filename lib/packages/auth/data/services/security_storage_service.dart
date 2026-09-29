import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for storing and verifying credentials with AES encryption,
/// SHA-256 password hashing, and platform-level FlutterSecureStorage.
class SecurityStorageService {
  static const String _defaultUserEmail = 'admin@coozy.com';
  static const String _defaultUserPassword = 'admin123';

  static const String _storageKeyPasswordHash = 'auth_password_hash_encrypted';
  static const String _storageKeyUserEmail = 'auth_user_email';

  // Fixed internal key & IV derivation for credential encryption at rest
  static final enc.Key _encKey = enc.Key(
    Uint8List.fromList(
      sha256.convert(utf8.encode('coozy_the_cafe_secure_salt_2026')).bytes,
    ),
  );
  static final enc.IV _encIv = enc.IV(
    Uint8List.fromList(
      md5.convert(utf8.encode('coozy_cafe_iv_vector')).bytes,
    ),
  );

  final FlutterSecureStorage _secureStorage;

  SecurityStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Computes a cryptographically secure SHA-256 hash of [plainPassword] with salt.
  String hashPassword(String plainPassword) {
    final saltedBytes = utf8.encode('coozy_auth_salt_${plainPassword.trim()}');
    return sha256.convert(saltedBytes).toString();
  }

  /// Encrypts string data with AES-256 before saving to secure storage.
  String _encrypt(String plainText) {
    final encrypter = enc.Encrypter(enc.AES(_encKey, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: _encIv);
    return encrypted.base64;
  }

  /// Decrypts AES-256 encrypted base64 payload.
  String _decrypt(String cipherBase64) {
    final encrypter = enc.Encrypter(enc.AES(_encKey, mode: enc.AESMode.cbc));
    return encrypter.decrypt(enc.Encrypted.fromBase64(cipherBase64), iv: _encIv);
  }

  /// Ensures an initial password exists in secure storage.
  /// If not set yet, defaults to 'admin123'.
  Future<void> initDefaultPasswordIfNeeded() async {
    try {
      final currentHash = await _secureStorage.read(key: _storageKeyPasswordHash);
      if (currentHash == null || currentHash.isEmpty) {
        await savePassword(_defaultUserPassword);
      }
      final currentEmail = await _secureStorage.read(key: _storageKeyUserEmail);
      if (currentEmail == null || currentEmail.isEmpty) {
        await _secureStorage.write(key: _storageKeyUserEmail, value: _defaultUserEmail);
      }
    } catch (_) {
      // In case of platform-specific secure storage read error, set initial
      await savePassword(_defaultUserPassword);
    }
  }

  /// Saves the new password: computes SHA-256 hash, encrypts with AES,
  /// and writes to secure storage.
  Future<void> savePassword(String newPlainPassword) async {
    final hashed = hashPassword(newPlainPassword);
    final encryptedHash = _encrypt(hashed);
    await _secureStorage.write(
      key: _storageKeyPasswordHash,
      value: encryptedHash,
    );
  }

  /// Verifies whether [candidatePassword] matches the stored password.
  Future<bool> verifyPassword(String candidatePassword) async {
    await initDefaultPasswordIfNeeded();
    final encryptedHash = await _secureStorage.read(key: _storageKeyPasswordHash);
    if (encryptedHash == null || encryptedHash.isEmpty) {
      return candidatePassword.trim() == _defaultUserPassword;
    }
    try {
      final storedHash = _decrypt(encryptedHash);
      final candidateHash = hashPassword(candidatePassword);
      return storedHash == candidateHash;
    } catch (_) {
      // Fallback verification if decryption fails
      return candidatePassword.trim() == _defaultUserPassword;
    }
  }

  /// Reads stored email address or defaults to admin email.
  Future<String> getStoredEmail() async {
    final email = await _secureStorage.read(key: _storageKeyUserEmail);
    return email ?? _defaultUserEmail;
  }

  /// Clears password from secure storage and resets to default.
  Future<void> resetToDefault() async {
    await savePassword(_defaultUserPassword);
  }
}

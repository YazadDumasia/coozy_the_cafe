import 'dart:math';

/// Utility service to generate cryptographically strong, random passwords
/// complying with all password complexity requirements.
class PasswordGenerator {
  PasswordGenerator._();

  static const String _lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numberChars = '0123456789';
  static const String _specialChars = '!@#\$&*~+-';

  /// Generates a cryptographically strong, random password.
  /// Guarantees:
  /// - At least 1 lowercase letter
  /// - At least 1 uppercase letter
  /// - At least 1 number
  /// - At least 1 special character from `!@#$&*~+-`
  /// - Total length (default: 14, min: 8)
  static String generate({int length = 14}) {
    final int targetLength = length < 8 ? 8 : length;
    final Random random = Random.secure();

    final List<String> passwordChars = <String>[];

    // Ensure at least one character from each required category
    passwordChars.add(_lowercaseChars[random.nextInt(_lowercaseChars.length)]);
    passwordChars.add(_uppercaseChars[random.nextInt(_uppercaseChars.length)]);
    passwordChars.add(_numberChars[random.nextInt(_numberChars.length)]);
    passwordChars.add(_specialChars[random.nextInt(_specialChars.length)]);

    // Fill the remainder from the combined character pool
    const String allChars =
        '$_lowercaseChars$_uppercaseChars$_numberChars$_specialChars';

    for (int i = passwordChars.length; i < targetLength; i++) {
      passwordChars.add(allChars[random.nextInt(allChars.length)]);
    }

    // Fisher-Yates cryptographically secure shuffle
    for (int i = passwordChars.length - 1; i > 0; i--) {
      final int j = random.nextInt(i + 1);
      final String temp = passwordChars[i];
      passwordChars[i] = passwordChars[j];
      passwordChars[j] = temp;
    }

    return passwordChars.join('');
  }

  /// Convenience alias for [generate].
  static String generateStrongPassword({int length = 14}) =>
      generate(length: length);
}

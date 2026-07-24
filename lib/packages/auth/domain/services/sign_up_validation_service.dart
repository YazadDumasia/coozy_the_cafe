class SignUpValidationService {
  SignUpValidationService();

  final RegExp numericRegex = RegExp(r'(?=.*[0-9])');
  final RegExp oneUpperCaseRegex = RegExp(r'(?=.*[A-Z])');
  final RegExp oneLowerCaseRegex = RegExp(r'(?=.*[a-z])');
  final RegExp oneSpecialCharRegex = RegExp(r'(?=.*[!@#$&*~+-])');

  bool hasLowerCase(String password) => oneLowerCaseRegex.hasMatch(password);
  bool hasUpperCase(String password) => oneUpperCaseRegex.hasMatch(password);
  bool hasNumeric(String password) => numericRegex.hasMatch(password);
  bool hasSpecialChar(String password) =>
      oneSpecialCharRegex.hasMatch(password);
  bool hasMinLength(String password, {int minLength = 8}) =>
      password.length >= minLength;

  bool validatePasswordFull(String password) {
    return hasLowerCase(password) &&
        hasUpperCase(password) &&
        hasNumeric(password) &&
        hasSpecialChar(password) &&
        hasMinLength(password);
  }

  bool validateConfirmPassword(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}

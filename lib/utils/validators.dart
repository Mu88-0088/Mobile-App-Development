class Validators {
  static String? email(String? val) {
    if (val == null || val.isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!re.hasMatch(val)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? val) {
    if (val == null || val.isEmpty) return 'Password is required';
    if (val.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? val, String original) {
    if (val == null || val.isEmpty) return 'Please confirm your password';
    if (val != original) return 'Passwords do not match';
    return null;
  }

  static String? name(String? val) {
    if (val == null || val.isEmpty) return 'Name is required';
    if (val.trim().length < 2) return 'Name is too short';
    return null;
  }

  static String? phone(String? val) {
    if (val == null || val.isEmpty) return 'Phone number is required';
    final re = RegExp(r'^[0-9+]{9,15}$');
    if (!re.hasMatch(val.replaceAll(' ', ''))) return 'Enter a valid phone number';
    return null;
  }

  static String? required(String? val, {String field = 'This field'}) {
    if (val == null || val.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? positiveNumber(String? val, {String field = 'Value'}) {
    if (val == null || val.isEmpty) return '$field is required';
    final n = double.tryParse(val);
    if (n == null) return '$field must be a number';
    if (n <= 0) return '$field must be greater than 0';
    return null;
  }
}

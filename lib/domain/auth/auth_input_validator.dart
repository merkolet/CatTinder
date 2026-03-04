class AuthInputValidator {
  const AuthInputValidator();

  String? validateEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return 'Введите email';
    if (!trimmed.contains('@')) return 'Некорректный email';
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Введите пароль';
    if (password.length < 6) return 'Минимум 6 символов';
    return null;
  }
}


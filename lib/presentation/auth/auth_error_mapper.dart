import 'package:firebase_auth/firebase_auth.dart';

String mapSignInError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Некорректный email';
      case 'user-disabled':
        return 'Аккаунт отключен';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неверный email или пароль';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'network-request-failed':
        return 'Проблема с сетью. Проверьте интернет';
      default:
        return 'Системная ошибка входа. Попробуйте позже';
    }
  }

  return 'Системная ошибка входа. Попробуйте позже';
}

String mapSignUpError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Этот email уже используется';
      case 'invalid-email':
        return 'Некорректный email';
      case 'weak-password':
        return 'Слишком простой пароль';
      case 'operation-not-allowed':
        return 'Регистрация сейчас недоступна';
      case 'network-request-failed':
        return 'Проблема с сетью. Проверьте интернет';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      default:
        return 'Системная ошибка регистрации. Попробуйте позже';
    }
  }

  return 'Системная ошибка регистрации. Попробуйте позже';
}


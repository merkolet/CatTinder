import '../repositories/auth_repository.dart';
import 'auth_input_validator.dart';
import 'auth_result.dart';

class SignInUseCase {
  const SignInUseCase({
    required AuthRepository authRepository,
    this.validator = const AuthInputValidator(),
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;
  final AuthInputValidator validator;

  Future<AuthResult> call({
    required String email,
    required String password,
  }) async {
    final emailError = validator.validateEmail(email);
    if (emailError != null) {
      return AuthResult.failure(
        type: AuthFailureType.validation,
        message: emailError,
      );
    }

    final passwordError = validator.validatePassword(password);
    if (passwordError != null) {
      return AuthResult.failure(
        type: AuthFailureType.validation,
        message: passwordError,
      );
    }

    try {
      await _authRepository.signIn(email: email.trim(), password: password);
      return const AuthResult.success();
    } catch (_) {
      return const AuthResult.failure(
        type: AuthFailureType.system,
        message: 'Системная ошибка входа. Попробуйте позже',
      );
    }
  }
}


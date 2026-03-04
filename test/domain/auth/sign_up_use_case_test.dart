import 'package:cat_tinder/domain/auth/auth_result.dart';
import 'package:cat_tinder/domain/auth/sign_up_use_case.dart';
import 'package:cat_tinder/domain/entities/app_user.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  int signUpCalls = 0;
  String? lastSignUpEmail;
  String? lastSignUpPassword;
  Object? signUpError;

  @override
  Stream<AppUser?> authStateChanges() => const Stream.empty();

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    signUpCalls++;
    lastSignUpEmail = email;
    lastSignUpPassword = password;
    if (signUpError != null) throw signUpError!;
  }
}

Future<void> _runWithStatus(Future<void> Function() body) async {
  try {
    await body();
    debugPrint('✅ completed');
  } catch (_) {
    debugPrint('❌ Failed');
    rethrow;
  }
}

void main() {
  group('SignUpUseCase', () {
    test('Возвращает ошибку валидации при коротком пароле', () async {
      await _runWithStatus(() async {
        final repo = _FakeAuthRepository();
        final useCase = SignUpUseCase(authRepository: repo);

        final result = await useCase(email: 'user@test.com', password: '123');

        expect(result.isSuccess, isFalse);
        expect(result.failureType, AuthFailureType.validation);
        expect(result.message, 'Минимум 6 символов');
        expect(repo.signUpCalls, 0);
      });
    });

    test('Возвращает ошибку валидации при невалидном email', () async {
      await _runWithStatus(() async {
        final repo = _FakeAuthRepository();
        final useCase = SignUpUseCase(authRepository: repo);

        final result = await useCase(email: 'invalid-email', password: '123456');

        expect(result.isSuccess, isFalse);
        expect(result.failureType, AuthFailureType.validation);
        expect(result.message, 'Некорректный email');
        expect(repo.signUpCalls, 0);
      });
    });

    test('Успешно регистрирует пользователя', () async {
      await _runWithStatus(() async {
        final repo = _FakeAuthRepository();
        final useCase = SignUpUseCase(authRepository: repo);

        final result = await useCase(email: 'user@test.com', password: '123456');

        expect(result.isSuccess, isTrue);
        expect(repo.signUpCalls, 1);
        expect(repo.lastSignUpEmail, 'user@test.com');
      });
    });

    test('Возвращает системную ошибку, если репозиторий бросил исключение', () async {
      await _runWithStatus(() async {
        final repo = _FakeAuthRepository()..signUpError = StateError('boom');
        final useCase = SignUpUseCase(authRepository: repo);

        final result = await useCase(email: 'user@test.com', password: '123456');

        expect(result.isSuccess, isFalse);
        expect(result.failureType, AuthFailureType.system);
        expect(result.message, 'Системная ошибка регистрации. Попробуйте позже');
        expect(repo.signUpCalls, 1);
      });
    });
  });
}


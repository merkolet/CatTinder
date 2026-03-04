import 'package:cat_tinder/domain/auth/auth_result.dart';
import 'package:cat_tinder/domain/auth/sign_in_use_case.dart';
import 'package:cat_tinder/domain/entities/app_user.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  int signInCalls = 0;
  String? lastSignInEmail;
  String? lastSignInPassword;
  Object? signInError;

  @override
  Stream<AppUser?> authStateChanges() => const Stream.empty();

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    lastSignInEmail = email;
    lastSignInPassword = password;
    if (signInError != null) throw signInError!;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {}
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
  group('SignInUseCase', () {
    test('Возвращает ошибку валидации при невалидном email', () async {
      await _runWithStatus(() async {
        final repo = _FakeAuthRepository();
        final useCase = SignInUseCase(authRepository: repo);

        final result = await useCase(email: 'invalid-email', password: '123456');

        expect(result.isSuccess, isFalse);
        expect(result.failureType, AuthFailureType.validation);
        expect(result.message, 'Некорректный email');
        expect(repo.signInCalls, 0);
      });
    });

    test('Возвращает ошибку валидации при коротком пароле', () async {
      await _runWithStatus(() async {
        final repo = _FakeAuthRepository();
        final useCase = SignInUseCase(authRepository: repo);

        final result = await useCase(email: 'user@test.com', password: '123');

        expect(result.isSuccess, isFalse);
        expect(result.failureType, AuthFailureType.validation);
        expect(result.message, 'Минимум 6 символов');
        expect(repo.signInCalls, 0);
      });
    });

    test('Успешно логинит и отправляет email без пробелов', () async {
      await _runWithStatus(() async {
        final repo = _FakeAuthRepository();
        final useCase = SignInUseCase(authRepository: repo);

        final result = await useCase(
          email: '  user@test.com ',
          password: '123456',
        );

        expect(result.isSuccess, isTrue);
        expect(repo.signInCalls, 1);
        expect(repo.lastSignInEmail, 'user@test.com');
        expect(repo.lastSignInPassword, '123456');
      });
    });

    test('Возвращает системную ошибку, если репозиторий бросил исключение', () async {
      await _runWithStatus(() async {
        final repo = _FakeAuthRepository()..signInError = StateError('boom');
        final useCase = SignInUseCase(authRepository: repo);

        final result = await useCase(email: 'user@test.com', password: '123456');

        expect(result.isSuccess, isFalse);
        expect(result.failureType, AuthFailureType.system);
        expect(result.message, 'Системная ошибка входа. Попробуйте позже');
        expect(repo.signInCalls, 1);
      });
    });
  });
}


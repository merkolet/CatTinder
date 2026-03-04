import 'package:cat_tinder/domain/entities/app_user.dart';
import 'package:cat_tinder/domain/repositories/analytics_repository.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:cat_tinder/presentation/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAuthRepository implements AuthRepository {
  int signInCalls = 0;
  String? lastEmail;
  String? lastPassword;
  Object? signInError;

  @override
  Stream<AppUser?> authStateChanges() => const Stream.empty();

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    lastEmail = email;
    lastPassword = password;
    await Future<void>.delayed(const Duration(milliseconds: 20));
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

class _TestAnalyticsRepository implements AnalyticsRepository {
  int eventCalls = 0;
  String? lastName;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    eventCalls++;
    lastName = name;
  }
}

Future<void> _runWithStatus(Future<void> Function() body) async {
  try {
    await body();
    print('✅ completed');
  } catch (_) {
    print('❌ Failed');
    rethrow;
  }
}

void main() {
  Widget buildWidget({
    required AuthRepository authRepository,
    required AnalyticsRepository analyticsRepository,
  }) {
    return MaterialApp(
      home: LoginScreen(
        authRepository: authRepository,
        analyticsRepository: analyticsRepository,
      ),
    );
  }

  testWidgets('Показывает ошибки валидации при пустых полях', (tester) async {
    await _runWithStatus(() async {
      final repository = _TestAuthRepository();
      final analyticsRepository = _TestAnalyticsRepository();
      await tester.pumpWidget(
        buildWidget(
          authRepository: repository,
          analyticsRepository: analyticsRepository,
        ),
      );

      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Введите email'), findsOneWidget);
      expect(find.text('Введите пароль'), findsOneWidget);
      expect(repository.signInCalls, 0);
    });
  });

  testWidgets('Показывает ошибку валидации при невалидном email', (tester) async {
    await _runWithStatus(() async {
      final repository = _TestAuthRepository();
      final analyticsRepository = _TestAnalyticsRepository();
      await tester.pumpWidget(
        buildWidget(
          authRepository: repository,
          analyticsRepository: analyticsRepository,
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Некорректный email'), findsOneWidget);
      expect(repository.signInCalls, 0);
    });
  });

  testWidgets('Успешный вход вызывает репозиторий и показывает лоадер', (
    tester,
  ) async {
    await _runWithStatus(() async {
      final repository = _TestAuthRepository();
      final analyticsRepository = _TestAnalyticsRepository();
      await tester.pumpWidget(
        buildWidget(
          authRepository: repository,
          analyticsRepository: analyticsRepository,
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(repository.signInCalls, 1);
      expect(repository.lastEmail, 'user@test.com');

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  testWidgets('Показывает системную ошибку при исключении входа', (tester) async {
    await _runWithStatus(() async {
      final repository = _TestAuthRepository()..signInError = StateError('boom');
      final analyticsRepository = _TestAnalyticsRepository();
      await tester.pumpWidget(
        buildWidget(
          authRepository: repository,
          analyticsRepository: analyticsRepository,
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      expect(
        find.text('Системная ошибка входа. Попробуйте позже'),
        findsOneWidget,
      );
    });
  });

  testWidgets('Открывает экран регистрации с экрана входа', (tester) async {
    await _runWithStatus(() async {
      final repository = _TestAuthRepository();
      final analyticsRepository = _TestAnalyticsRepository();
      await tester.pumpWidget(
        buildWidget(
          authRepository: repository,
          analyticsRepository: analyticsRepository,
        ),
      );

      await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
      await tester.pumpAndSettle();

      expect(find.text('Создать аккаунт'), findsWidgets);
    });
  });
}


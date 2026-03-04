import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../data/repositories/firebase_analytics_repository.dart';
import '../data/repositories/cat_api_repository.dart';
import '../data/repositories/firebase_auth_repository.dart';
import '../data/repositories/local_likes_repository.dart';
import '../data/repositories/local_onboarding_repository.dart';
import '../domain/repositories/analytics_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/cat_repository.dart';
import '../domain/repositories/likes_repository.dart';
import '../domain/repositories/onboarding_repository.dart';

class AppDependencies {
  AppDependencies._({
    required this.catRepository,
    required this.authRepository,
    required this.onboardingRepository,
    required this.likesRepository,
    required this.analyticsRepository,
  });

  final CatRepository catRepository;
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  final LikesRepository likesRepository;
  final AnalyticsRepository analyticsRepository;

  factory AppDependencies.create() {
    final firebaseAuth = FirebaseAuth.instance;
    final firebaseAnalytics = FirebaseAnalytics.instance;
    return AppDependencies._(
      catRepository: CatApiRepository(),
      authRepository: FirebaseAuthRepository(firebaseAuth),
      onboardingRepository: LocalOnboardingRepository(),
      likesRepository: LocalLikesRepository(),
      analyticsRepository: FirebaseAnalyticsRepository(firebaseAnalytics),
    );
  }

  void dispose() {
    catRepository.dispose();
  }
}


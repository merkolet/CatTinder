import 'package:flutter/material.dart';

import '../../di/app_dependencies.dart';
import '../../domain/entities/app_user.dart';
import '../screens/main_tabs_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: dependencies.authRepository.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (user == null) {
          return LoginScreen(
            authRepository: dependencies.authRepository,
            analyticsRepository: dependencies.analyticsRepository,
          );
        }

        return MainTabsScreen(
          catRepository: dependencies.catRepository,
          authRepository: dependencies.authRepository,
          likesRepository: dependencies.likesRepository,
        );
      },
    );
  }
}


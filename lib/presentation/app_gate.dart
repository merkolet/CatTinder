import 'package:flutter/material.dart';

import '../di/app_dependencies.dart';
import 'auth/auth_gate.dart';
import 'onboarding/onboarding_screen.dart';

class AppGate extends StatefulWidget {
  const AppGate({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  late Future<bool> _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _onboardingCompleted =
        widget.dependencies.onboardingRepository.isCompleted();
  }

  void _onOnboardingCompleted() {
    setState(() {
      _onboardingCompleted = Future.value(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _onboardingCompleted,
      builder: (context, snapshot) {
        final isCompleted = snapshot.data;

        if (isCompleted == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!isCompleted) {
          return OnboardingScreen(
            onboardingRepository: widget.dependencies.onboardingRepository,
            onCompleted: _onOnboardingCompleted,
          );
        }

        return AuthGate(dependencies: widget.dependencies);
      },
    );
  }
}

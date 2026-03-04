import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'di/app_dependencies.dart';
import 'presentation/app_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (error) {
    runApp(StartupErrorApp(error: error.toString()));
    return;
  }
  runApp(const MainApp());
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({required this.error, super.key});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Не удалось инициализировать Firebase.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AppDependencies _dependencies;

  @override
  void initState() {
    super.initState();
    _dependencies = AppDependencies.create();
  }

  @override
  void dispose() {
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Кототиндер Pro😎',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFF2925A),
          secondary: Color(0xFF5BBF89),
          surface: Color(0xFFFFF6ED),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF6ED),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFFFFF6ED),
          foregroundColor: Color(0xFF2F2F2F),
          centerTitle: true,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: AppGate(dependencies: _dependencies),
    );
  }
}

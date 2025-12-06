import 'package:flutter/material.dart';

import 'screens/breeds_screen.dart';
import 'screens/cat_home_screen.dart';
import 'services/cat_api_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final CatApiService _service = CatApiService();

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Кототиндер',
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
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Кототиндер'),
            bottom: const TabBar(
              labelColor: Color(0xFFF2925A),
              unselectedLabelColor: Color(0xFF808080),
              indicatorColor: Color(0xFFF2925A),
              tabs: [
                Tab(icon: Icon(Icons.pets), text: 'Подборка'),
                Tab(icon: Icon(Icons.list_alt), text: 'Породы'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              CatHomeScreen(apiService: _service),
              BreedsScreen(apiService: _service),
            ],
          ),
        ),
      ),
    );
  }
}

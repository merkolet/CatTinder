import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/cat_repository.dart';
import '../../domain/repositories/likes_repository.dart';
import 'breeds_screen.dart';
import 'cat_home_screen.dart';

class MainTabsScreen extends StatelessWidget {
  const MainTabsScreen({
    required this.catRepository,
    required this.authRepository,
    required this.likesRepository,
    super.key,
  });

  final CatRepository catRepository;
  final AuthRepository authRepository;
  final LikesRepository likesRepository;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Кототиндер Pro😎'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Выйти',
              onPressed: () async {
                await authRepository.signOut();
                // AuthGate по стриму сам покажет экран логина
              },
            ),
          ],
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
            CatHomeScreen(
              catRepository: catRepository,
              likesRepository: likesRepository,
            ),
            BreedsScreen(catRepository: catRepository),
          ],
        ),
      ),
    );
  }
}


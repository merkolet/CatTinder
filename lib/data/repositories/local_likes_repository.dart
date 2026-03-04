import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/likes_repository.dart';

class LocalLikesRepository implements LikesRepository {
  static const _key = 'likes_count';

  @override
  Future<int> getLikesCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  @override
  Future<void> saveLikesCount(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, value);
  }
}


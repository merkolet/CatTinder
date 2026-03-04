abstract class LikesRepository {
  Future<int> getLikesCount();

  Future<void> saveLikesCount(int value);
}


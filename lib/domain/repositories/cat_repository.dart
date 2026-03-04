import '../entities/breed.dart';
import '../entities/cat_image.dart';

abstract class CatRepository {
  Future<CatImage> getRandomCat();

  Future<List<Breed>> getBreeds({bool forceRefresh = false});

  void dispose();
}


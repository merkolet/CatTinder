import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../domain/entities/breed.dart';
import '../../domain/entities/cat_image.dart';
import '../../domain/repositories/cat_repository.dart';

class CatApiRepository implements CatRepository {
  CatApiRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Random _random = Random();
  List<Breed>? _cachedBreeds;

  static const _baseUrl = 'https://api.thecatapi.com/v1';
  static const _apiKey = String.fromEnvironment('CAT_API_KEY');

  Map<String, String> get _headers {
    if (_apiKey.isEmpty) return const {'Content-Type': 'application/json'};
    return {'Content-Type': 'application/json', 'x-api-key': _apiKey};
  }

  @override
  Future<CatImage> getRandomCat() async {
    CatImage? lastCat;
    for (var attempt = 0; attempt < 3; attempt++) {
      final cat = await _fetchRandomCat();
      lastCat = cat;
      if (cat.breed != null) {
        return cat;
      }
    }
    final breedCat = await _fetchCatByRandomBreed();
    if (breedCat != null) return breedCat;
    if (lastCat != null) return lastCat;
    throw Exception('Не удалось получить котика');
  }

  Future<CatImage?> _fetchCatByRandomBreed() async {
    final breeds = await getBreeds();
    if (breeds.isEmpty) return null;
    final breed = breeds[_random.nextInt(breeds.length)];
    final uri = Uri.parse(
      '$_baseUrl/images/search?breed_ids=${breed.id}&include_breeds=1',
    );
    final response = await _client.get(uri, headers: _headers);
    _throwOnError(response);
    final body = jsonDecode(response.body) as List<dynamic>;
    if (body.isEmpty) return null;
    final cat = CatImage.fromJson(body.first as Map<String, dynamic>);
    return CatImage(id: cat.id, url: cat.url, breed: cat.breed ?? breed);
  }

  Future<CatImage> _fetchRandomCat() async {
    final uri = Uri.parse(
      '$_baseUrl/images/search?include_breeds=1&has_breeds=1',
    );
    final response = await _client.get(uri, headers: _headers);
    _throwOnError(response);
    final body = jsonDecode(response.body) as List<dynamic>;
    if (body.isEmpty) {
      throw Exception('Не удалось получить котика');
    }
    return CatImage.fromJson(body.first as Map<String, dynamic>);
  }

  @override
  Future<List<Breed>> getBreeds({bool forceRefresh = false}) async {
    final cachedBreeds = _cachedBreeds;
    if (!forceRefresh && cachedBreeds != null) {
      return cachedBreeds;
    }
    final uri = Uri.parse('$_baseUrl/breeds');
    final response = await _client.get(uri, headers: _headers);
    _throwOnError(response);
    final body = jsonDecode(response.body) as List<dynamic>;
    final breeds = body
        .map((dynamic e) => Breed.fromJson(e as Map<String, dynamic>))
        .toList();
    _cachedBreeds = breeds;
    return breeds;
  }

  void _throwOnError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Код ответа ${response.statusCode}: ${response.reasonPhrase ?? 'Ошибка'}',
      );
    }
  }

  @override
  void dispose() {
    _client.close();
  }
}


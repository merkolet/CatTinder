import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/breed.dart';
import '../models/cat_image.dart';

class CatApiService {
  CatApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Random _random = Random();
  List<Breed>? _cachedBreeds;

  static const _baseUrl = 'https://api.thecatapi.com/v1';
  static const _apiKey = String.fromEnvironment('CAT_API_KEY');

  Map<String, String> get _headers {
    if (_apiKey.isEmpty) return const {'Content-Type': 'application/json'};
    return {'Content-Type': 'application/json', 'x-api-key': _apiKey};
  }

  Future<CatImage> fetchRandomCat() async {
    CatImage? lastCat;
    for (var attempt = 0; attempt < 3; attempt++) {
      final cat = await _fetchRandomCat();
      lastCat = cat;
      if (cat.breed != null) {
        return cat;
      }
    }
    final breedCat = await _fetchCatByRandomBreed();
    return breedCat ?? lastCat!;
  }

  Future<CatImage?> _fetchCatByRandomBreed() async {
    final breeds = await fetchBreeds();
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

  Future<List<Breed>> fetchBreeds({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedBreeds != null) {
      return _cachedBreeds!;
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

  void dispose() {
    _client.close();
  }
}

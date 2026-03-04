import 'breed.dart';

class CatImage {
  const CatImage({required this.id, required this.url, required this.breed});

  final String id;
  final String url;
  final Breed? breed;

  factory CatImage.fromJson(Map<String, dynamic> json) {
    final breeds = json['breeds'] as List<dynamic>?;
    final breedJson = breeds != null && breeds.isNotEmpty
        ? breeds.first as Map<String, dynamic>
        : null;
    return CatImage(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      breed: breedJson != null ? Breed.fromJson(breedJson) : null,
    );
  }
}


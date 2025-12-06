import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/breed.dart';
import '../models/cat_image.dart';

class CatDetailScreen extends StatelessWidget {
  const CatDetailScreen({required this.cat, super.key});

  final CatImage cat;

  @override
  Widget build(BuildContext context) {
    final breed = cat.breed;
    return Scaffold(
      appBar: AppBar(title: Text(breed?.name ?? 'Котик')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 340,
                    maxWidth: 520,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: CachedNetworkImage(
                      imageUrl: cat.url,
                      fit: BoxFit.cover,
                      placeholder: (context, _) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, _, __) =>
                          const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    breed?.name ?? 'Неизвестная порода',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    breed?.origin ?? 'Неизвестное происхождение',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    breed?.description ??
                        'Для этой фотографии нет описания, но котик все равно чудесный!',
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  if (breed != null) _buildCharacteristics(breed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristics(Breed breed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Характеристики',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _CharacteristicRow(label: 'Темперамент', value: breed.temperament),
        _CharacteristicRow(label: 'Порода', value: breed.origin),
        _CharacteristicRow(
          label: 'Продолжительность жизни',
          value: '${breed.lifeSpan} лет',
        ),
        _CharacteristicRow(
          label: 'Ласковость',
          value: _valueToEmoji(breed.affectionLevel),
        ),
        _CharacteristicRow(
          label: 'Интеллект',
          value: _valueToEmoji(breed.intelligence),
        ),
      ],
    );
  }

  String _valueToEmoji(int value) {
    final clamped = (value.clamp(1, 5) as num).toInt();
    return List.generate(clamped, (_) => '⭐').join();
  }
}

class _CharacteristicRow extends StatelessWidget {
  const _CharacteristicRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}

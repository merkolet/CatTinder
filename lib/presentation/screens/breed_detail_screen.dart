import 'package:flutter/material.dart';

import '../../domain/entities/breed.dart';

class BreedDetailScreen extends StatelessWidget {
  const BreedDetailScreen({required this.breed, super.key});

  final Breed breed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(breed.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 16),
            Text(
              breed.description,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),
            _buildGrid(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFF7C188), Color(0xFFF2925A)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            breed.name.characters.first.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              breed.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '${breed.origin} · ${breed.lifeSpan} лет',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Характеристики',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 12),
        _StatTile(title: 'Ласковость', value: breed.affectionLevel),
        _StatTile(title: 'Адаптивность', value: breed.adaptability),
        _StatTile(title: 'Интеллект', value: breed.intelligence),
        _StatTile(title: 'Темперамент', custom: breed.temperament),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.title, this.value, this.custom});

  final String title;
  final int? value;
  final String? custom;

  @override
  Widget build(BuildContext context) {
    final stars = switch (value) {
      final int raw => List.generate(raw.clamp(1, 5), (_) => '⭐').join(),
      null => custom ?? '',
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Text(stars, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}


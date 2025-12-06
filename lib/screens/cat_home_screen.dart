import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/cat_image.dart';
import '../services/cat_api_service.dart';
import 'cat_detail_screen.dart';

class CatHomeScreen extends StatefulWidget {
  const CatHomeScreen({required this.apiService, super.key});

  final CatApiService apiService;

  @override
  State<CatHomeScreen> createState() => _CatHomeScreenState();
}

class _CatHomeScreenState extends State<CatHomeScreen>
    with AutomaticKeepAliveClientMixin {
  CatImage? _currentCat;
  bool _loading = true;
  bool _hasError = false;
  int _likes = 0;

  @override
  void initState() {
    super.initState();
    _loadCat();
  }

  Future<void> _loadCat() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final cat = await widget.apiService.fetchRandomCat();
      if (!mounted) return;
      setState(() {
        _currentCat = cat;
      });
    } catch (e) {
      _showErrorDialog(e.toString());
      setState(() {
        _hasError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _handleAction(bool liked) {
    setState(() {
      if (liked) {
        _likes++;
      }
      // Убираем текущую карточку из дерева, чтобы Dismissible не остался.
      _currentCat = null;
    });
    _loadCat();
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Упс, ошибка'),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Ок'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadCat();
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cat = _currentCat;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              _LikesBadge(likes: _likes),
              const SizedBox(height: 8),
              Expanded(child: Center(child: _buildCatCard(cat))),
              const SizedBox(height: 16),
              _ActionButtons(
                onDislike: () => _handleAction(false),
                onLike: () => _handleAction(true),
                enabled: !_loading && !_hasError,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        if (_loading)
          Container(
            color: Colors.black.withValues(alpha: 0.04),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildCatCard(CatImage? cat) {
    if (_hasError) {
      return const Text(
        'Не удалось загрузить котика :(',
        style: TextStyle(fontSize: 16),
      );
    }
    if (cat == null) {
      return const SizedBox.shrink();
    }
    final breedName = cat.breed?.name ?? 'Неизвестная порода';
    return Dismissible(
      key: ValueKey(cat.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        final liked = direction == DismissDirection.startToEnd;
        _handleAction(liked);
      },
      child: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => CatDetailScreen(cat: cat)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: cat.url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  placeholder: (context, _) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, _, __) =>
                      const Icon(Icons.broken_image, size: 48),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      breedName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.breed?.temperament ?? 'Без характера',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onDislike,
    required this.onLike,
    required this.enabled,
  });

  final VoidCallback onDislike;
  final VoidCallback onLike;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RoundButton(
          icon: Icons.close,
          color: const Color(0xFFEC6E64),
          onPressed: enabled ? onDislike : null,
        ),
        _RoundButton(
          icon: Icons.favorite,
          color: const Color(0xFF5BBF89),
          onPressed: enabled ? onLike : null,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(18),
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: color.withValues(alpha: 0.4),
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 30),
    );
  }
}

class _LikesBadge extends StatelessWidget {
  const _LikesBadge({required this.likes});

  final int likes;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFCE2C6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Color(0xFFD65D60)),
            const SizedBox(width: 8),
            Text(
              '$likes',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

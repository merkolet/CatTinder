import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/repositories/onboarding_repository.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.onboardingRepository,
    required this.onCompleted,
    super.key,
  });

  final OnboardingRepository onboardingRepository;
  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Анимация котика: прыжок + масштаб при смене страницы
  late AnimationController _catController;
  late Animation<double> _catJump;
  late Animation<double> _catRotation;
  late Animation<double> _catScale;

  static const _pages = [
    _OnboardingPage(
      emoji: '😻',
      title: 'Свайпай котиков',
      description:
          'Листай карточки влево и вправо.\n'
          'Нравится — свайп вправо или кнопка ❤️.\n'
          'Не твой тип — свайп влево или кнопка ✖️.',
      color: Color(0xFFFFF6ED),
      accentColor: Color(0xFFF2925A),
    ),
    _OnboardingPage(
      emoji: '🔍',
      title: 'Узнай всё о породе',
      description:
          'Нажми на карточку — откроется подробная\n'
          'информация о породе: темперамент,\n'
          'происхождение и характеристики.',
      color: Color(0xFFF0FBF5),
      accentColor: Color(0xFF5BBF89),
    ),
    _OnboardingPage(
      emoji: '📋',
      title: 'Все породы рядом',
      description:
          'Во вкладке «Породы» собраны все породы.\n'
          'Ищи, изучай и выбирай\n'
          'самого любимого котика!',
      color: Color(0xFFF0F4FF),
      accentColor: Color(0xFF6B8DD6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _catController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _catJump = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
        parent: _catController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _catRotation = Tween<double>(begin: -0.18, end: 0.0).animate(
      CurvedAnimation(
        parent: _catController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );
    _catScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _catController,
        curve: const Interval(0.0, 0.75, curve: Curves.elasticOut),
      ),
    );
    _catController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _catController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _catController.reset();
    _catController.forward();
  }

  Future<void> _complete() async {
    await widget.onboardingRepository.markCompleted();
    widget.onCompleted();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: page.color,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageView(
                    page: _pages[index],
                    catController: _catController,
                    catJump: _catJump,
                    catRotation: _catRotation,
                    catScale: _catScale,
                    isActive: index == _currentPage,
                  );
                },
              ),
            ),
            _BottomControls(
              currentPage: _currentPage,
              totalPages: _pages.length,
              accentColor: page.accentColor,
              onNext: _nextPage,
              onSkip: _complete,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.page,
    required this.catController,
    required this.catJump,
    required this.catRotation,
    required this.catScale,
    required this.isActive,
  });

  final _OnboardingPage page;
  final AnimationController catController;
  final Animation<double> catJump;
  final Animation<double> catRotation;
  final Animation<double> catScale;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: catController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, isActive ? catJump.value : 0),
                child: Transform.rotate(
                  angle: isActive ? catRotation.value : 0,
                  child: Transform.scale(
                    scale: isActive ? catScale.value : 1.0,
                    child: child,
                  ),
                ),
              );
            },
            child: _CatEmoji(
              emoji: page.emoji,
              accentColor: page.accentColor,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: page.accentColor,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xFF555555),
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CatEmoji extends StatelessWidget {
  const _CatEmoji({required this.emoji, required this.accentColor});

  final String emoji;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 190,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentColor.withValues(alpha: 0.13),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.30),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(
            fontSize: 96,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.accentColor,
    required this.onNext,
    required this.onSkip,
  });

  final int currentPage;
  final int totalPages;
  final Color accentColor;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  bool get _isLast => currentPage == totalPages - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!_isLast)
            TextButton(
              onPressed: onSkip,
              child: Text(
                'Пропустить',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
              ),
            )
          else
            const SizedBox(width: 100),
          const Spacer(),
          _Dots(
            currentPage: currentPage,
            totalPages: totalPages,
            accentColor: accentColor,
          ),
          const Spacer(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                shadowColor: accentColor.withValues(alpha: 0.4),
              ),
              onPressed: onNext,
              child: Text(
                _isLast ? 'Начать!' : 'Далее',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.currentPage,
    required this.totalPages,
    required this.accentColor,
  });

  final int currentPage;
  final int totalPages;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? accentColor : accentColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.accentColor,
  });

  final String emoji;
  final String title;
  final String description;
  final Color color;
  final Color accentColor;
}

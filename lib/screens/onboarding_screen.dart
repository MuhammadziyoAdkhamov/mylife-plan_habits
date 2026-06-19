import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      titleType: _OnboardingTitleType.welcome,
      title: 'Welcome to',
      message: 'A better you starts\nwith a better plan.',
      visual: _OnboardingVisual.mountain,
      buttonText: 'Get Started',
      showAccountText: true,
      showPlus: false,
    ),
    _OnboardingData(
      titleType: _OnboardingTitleType.normal,
      title: 'Small Steps,\nBig Changes',
      message:
          'We help you build good habits\nand break bad ones with\nscience-backed methods.',
      visual: _OnboardingVisual.steps,
      buttonText: 'Next',
      showAccountText: false,
      showPlus: true,
    ),
    _OnboardingData(
      titleType: _OnboardingTitleType.normal,
      title: 'Track. Improve.\nTransform.',
      message:
          'Track your progress, earn XP,\nand become the best\nversion of yourself.',
      visual: _OnboardingVisual.orb,
      buttonText: 'Let\'s Go!',
      showAccountText: false,
      showPlus: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < _pages.length - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await context.read<AppState>().completeOnboarding();
    if (mounted) context.go('/login');
  }

  Future<void> _goLogin() async {
    await context.read<AppState>().completeOnboarding();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final current = _pages[_page];

    return Scaffold(
      backgroundColor: const Color(0xFF020712),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF07122F),
              Color(0xFF040817),
              Color(0xFF02040B),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _OnboardingBackgroundPainter(),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (value) {
                        setState(() => _page = value);
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _OnboardingPage(
                          data: _pages[index],
                          index: index,
                          onPlusTap: _next,
                        );
                      },
                    ),
                  ),
                  _PageDots(
                    activeIndex: _page,
                    count: 4,
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        text: current.buttonText,
                        height: 55,
                        onPressed: _next,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: current.showAccountText
                        ? Padding(
                            key: const ValueKey('account_text'),
                            padding: const EdgeInsets.only(top: 13),
                            child: TextButton(
                              onPressed: _goLogin,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(
                                'I already have an account',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.66),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          )
                        : const SizedBox(
                            key: ValueKey('empty_account_text'),
                            height: 48,
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.index,
    required this.onPlusTap,
  });

  final _OnboardingData data;
  final int index;
  final VoidCallback onPlusTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (data.showPlus)
          Positioned(
            top: 14,
            right: 20,
            child: _SmallPlusButton(onTap: onPlusTap),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: data.showPlus ? 58 : 56),
              _OnboardingTitle(data: data),
              const SizedBox(height: 14),
              Text(
                data.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.74),
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: RepaintBoundary(
                  child: SizedBox.expand(
                    child: CustomPaint(
                      painter: switch (data.visual) {
                        _OnboardingVisual.mountain =>
                          _MountainIllustrationPainter(),
                        _OnboardingVisual.steps => _StepsIllustrationPainter(),
                        _OnboardingVisual.orb => _OrbIllustrationPainter(),
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingTitle extends StatelessWidget {
  const _OnboardingTitle({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 26,
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ) ??
        const TextStyle(
          fontSize: 26,
          height: 1.08,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        );

    if (data.titleType == _OnboardingTitleType.welcome) {
      return Column(
        children: [
          Text(
            'Welcome to',
            textAlign: TextAlign.center,
            style: baseStyle,
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GradientText(
                'MYLife',
                style: baseStyle.copyWith(fontSize: 27),
              ),
              Text(
                ' Plan',
                style: baseStyle.copyWith(fontSize: 27),
              ),
            ],
          ),
        ],
      );
    }

    return Text(
      data.title,
      textAlign: TextAlign.center,
      style: baseStyle,
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(
    this.text, {
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF22D3EE),
            Color(0xFF4B6BFF),
            Color(0xFF9B5CFF),
          ],
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.activeIndex,
    required this.count,
  });

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == activeIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: active ? 13 : 7,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: active
                ? const Color(0xFF5B6CFF)
                : Colors.white.withOpacity(0.18),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF5B6CFF).withOpacity(0.45),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

class _SmallPlusButton extends StatefulWidget {
  const _SmallPlusButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_SmallPlusButton> createState() => _SmallPlusButtonState();
}

class _SmallPlusButtonState extends State<_SmallPlusButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 130),
        scale: _pressed ? 0.9 : 1,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.42),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

enum _OnboardingVisual {
  mountain,
  steps,
  orb,
}

enum _OnboardingTitleType {
  welcome,
  normal,
}

class _OnboardingData {
  const _OnboardingData({
    required this.titleType,
    required this.title,
    required this.message,
    required this.visual,
    required this.buttonText,
    required this.showAccountText,
    required this.showPlus,
  });

  final _OnboardingTitleType titleType;
  final String title;
  final String message;
  final _OnboardingVisual visual;
  final String buttonText;
  final bool showAccountText;
  final bool showPlus;
}

class _OnboardingBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF061133),
          Color(0xFF030817),
          Color(0xFF02030A),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, bgPaint);

    final topGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4B6BFF).withOpacity(0.18),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, -40),
          radius: size.width * 0.9,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.5, -40),
      size.width * 0.9,
      topGlow,
    );

    final starPaint = Paint()..color = Colors.white.withOpacity(0.72);
    final blueStarPaint = Paint()..color = const Color(0xFF7C8DFF);

    for (int i = 0; i < 44; i++) {
      final dx = ((i * 41 + 19) % 100) / 100 * size.width;
      final dy = ((i * 67 + 11) % 100) / 100 * size.height * 0.78;
      final radius = i % 9 == 0 ? 1.55 : 0.82;

      canvas.drawCircle(
        Offset(dx, dy),
        radius,
        i % 7 == 0 ? blueStarPaint : starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MountainIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final skyGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF8A65).withOpacity(0.32),
          const Color(0xFF8B5CF6).withOpacity(0.18),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(w * 0.5, h * 0.58),
          radius: w * 0.5,
        ),
      );

    canvas.drawCircle(Offset(w * 0.5, h * 0.58), w * 0.5, skyGlow);

    _drawStars(canvas, size);

    final farMountains = Path()
      ..moveTo(0, h * 0.72)
      ..lineTo(w * 0.18, h * 0.54)
      ..lineTo(w * 0.33, h * 0.66)
      ..lineTo(w * 0.49, h * 0.47)
      ..lineTo(w * 0.65, h * 0.66)
      ..lineTo(w * 0.82, h * 0.51)
      ..lineTo(w, h * 0.70)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      farMountains,
      Paint()..color = const Color(0xFF35236B).withOpacity(0.85),
    );

    final midMountains = Path()
      ..moveTo(0, h * 0.78)
      ..lineTo(w * 0.20, h * 0.62)
      ..lineTo(w * 0.38, h * 0.74)
      ..lineTo(w * 0.58, h * 0.54)
      ..lineTo(w * 0.77, h * 0.75)
      ..lineTo(w, h * 0.61)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      midMountains,
      Paint()..color = const Color(0xFF151C4A),
    );

    final frontMountains = Path()
      ..moveTo(0, h * 0.88)
      ..lineTo(w * 0.22, h * 0.72)
      ..lineTo(w * 0.36, h * 0.84)
      ..lineTo(w * 0.51, h * 0.61)
      ..lineTo(w * 0.68, h * 0.84)
      ..lineTo(w * 0.88, h * 0.71)
      ..lineTo(w, h * 0.86)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      frontMountains,
      Paint()..color = const Color(0xFF060B1E),
    );

    final peak = Offset(w * 0.50, h * 0.61);
    _drawPersonWithFlag(canvas, peak);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.72);

    final stars = [
      Offset(size.width * .17, size.height * .08),
      Offset(size.width * .32, size.height * .20),
      Offset(size.width * .73, size.height * .13),
      Offset(size.width * .84, size.height * .29),
      Offset(size.width * .55, size.height * .25),
      Offset(size.width * .20, size.height * .37),
    ];

    for (final star in stars) {
      canvas.drawCircle(star, 1.2, paint);
    }

    final crossPaint = Paint()
      ..color = const Color(0xFFC9B6FF).withOpacity(0.9)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width * .82, size.height * .09);
    canvas.drawLine(
      center.translate(-5, 0),
      center.translate(5, 0),
      crossPaint,
    );
    canvas.drawLine(
      center.translate(0, -5),
      center.translate(0, 5),
      crossPaint,
    );
  }

  void _drawPersonWithFlag(Canvas canvas, Offset base) {
    final bodyPaint = Paint()
      ..color = const Color(0xFFBFD7FF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final darkPaint = Paint()
      ..color = const Color(0xFF0E1A35)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final skinPaint = Paint()..color = const Color(0xFFFFD0A8);
    final purplePaint = Paint()..color = const Color(0xFFB66BFF);

    final head = base.translate(-5, -54);
    canvas.drawCircle(head, 5, skinPaint);

    canvas.drawLine(
      base.translate(-4, -47),
      base.translate(-5, -24),
      bodyPaint,
    );

    canvas.drawLine(
      base.translate(-5, -24),
      base.translate(-17, -4),
      darkPaint,
    );
    canvas.drawLine(
      base.translate(-5, -24),
      base.translate(8, -4),
      darkPaint,
    );

    canvas.drawLine(
      base.translate(-5, -40),
      base.translate(-20, -31),
      bodyPaint,
    );

    final polePaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final poleBottom = base.translate(14, -5);
    final poleTop = base.translate(14, -74);
    canvas.drawLine(poleBottom, poleTop, polePaint);

    final flag = Path()
      ..moveTo(poleTop.dx, poleTop.dy + 3)
      ..quadraticBezierTo(
        poleTop.dx + 28,
        poleTop.dy + 7,
        poleTop.dx + 42,
        poleTop.dy + 1,
      )
      ..lineTo(poleTop.dx + 38, poleTop.dy + 24)
      ..quadraticBezierTo(
        poleTop.dx + 20,
        poleTop.dy + 18,
        poleTop.dx,
        poleTop.dy + 24,
      )
      ..close();

    canvas.drawPath(flag, purplePaint);

    final starPaint = Paint()..color = Colors.white.withOpacity(0.9);
    final starCenter = poleTop.translate(22, 12);
    canvas.drawCircle(starCenter, 3, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StepsIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawStars(canvas, size);

    final centerX = size.width * 0.52;

    _drawStep(
      canvas,
      Offset(centerX - 42, size.height * 0.66),
      116,
      const Color(0xFF22D3EE),
      const Color(0xFF4B6BFF),
    );

    _drawStep(
      canvas,
      Offset(centerX + 10, size.height * 0.51),
      108,
      const Color(0xFF4B6BFF),
      const Color(0xFF8B5CF6),
    );

    _drawStep(
      canvas,
      Offset(centerX + 54, size.height * 0.37),
      95,
      const Color(0xFF8B5CF6),
      const Color(0xFF7C5CFF),
    );
  }

  void _drawStars(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Colors.white.withOpacity(0.75);
    final violetPaint = Paint()..color = const Color(0xFF9B8CFF);

    for (int i = 0; i < 28; i++) {
      final dx = ((i * 53 + 9) % 100) / 100 * size.width;
      final dy = ((i * 31 + 17) % 100) / 100 * size.height * 0.9;
      canvas.drawCircle(
        Offset(dx, dy),
        i % 8 == 0 ? 1.7 : 0.9,
        i % 5 == 0 ? violetPaint : starPaint,
      );
    }
  }

  void _drawStep(
    Canvas canvas,
    Offset center,
    double width,
    Color start,
    Color end,
  ) {
    final top = Path()
      ..moveTo(center.dx - width * 0.50, center.dy)
      ..lineTo(center.dx - width * 0.08, center.dy - width * 0.17)
      ..lineTo(center.dx + width * 0.50, center.dy + width * 0.03)
      ..lineTo(center.dx + width * 0.05, center.dy + width * 0.22)
      ..close();

    final side = Path()
      ..moveTo(center.dx - width * 0.50, center.dy)
      ..lineTo(center.dx + width * 0.05, center.dy + width * 0.22)
      ..lineTo(center.dx + width * 0.05, center.dy + width * 0.34)
      ..lineTo(center.dx - width * 0.50, center.dy + width * 0.12)
      ..close();

    final front = Path()
      ..moveTo(center.dx + width * 0.05, center.dy + width * 0.22)
      ..lineTo(center.dx + width * 0.50, center.dy + width * 0.03)
      ..lineTo(center.dx + width * 0.50, center.dy + width * 0.16)
      ..lineTo(center.dx + width * 0.05, center.dy + width * 0.34)
      ..close();

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          start.withOpacity(0.45),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center.translate(0, width * 0.08),
          radius: width * 0.72,
        ),
      );

    canvas.drawCircle(center.translate(0, width * 0.08), width * 0.72, glow);

    canvas.drawPath(
      side,
      Paint()..color = const Color(0xFF0B1535),
    );

    canvas.drawPath(
      front,
      Paint()..color = const Color(0xFF18245B),
    );

    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ).createShader(top.getBounds()),
    );

    canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withOpacity(0.18),
    );

    final shine = Paint()
      ..color = Colors.white.withOpacity(0.62)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center.translate(-10, 2),
      center.translate(14, -7),
      shine,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrbIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawStars(canvas, size);

    final center = Offset(size.width * 0.5, size.height * 0.47);
    final radius = math.min(size.width, size.height) * 0.22;

    final outerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4B6BFF).withOpacity(0.52),
          const Color(0xFF7C5CFF).withOpacity(0.18),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 2.15),
      );

    canvas.drawCircle(center, radius * 2.15, outerGlow);

    for (int i = 0; i < 4; i++) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 1 ? 4 : 1.3
        ..color = [
          const Color(0xFF7C5CFF).withOpacity(0.55),
          const Color(0xFF4B6BFF).withOpacity(0.9),
          const Color(0xFF22D3EE).withOpacity(0.32),
          Colors.white.withOpacity(0.12),
        ][i];

      canvas.drawCircle(center, radius + i * 15, ringPaint);
    }

    final starPath = _starPath(
      center: center,
      outerRadius: radius * 0.62,
      innerRadius: radius * 0.20,
      points: 4,
    );

    canvas.drawPath(
      starPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFF22D3EE),
            Color(0xFF7C5CFF),
          ],
        ).createShader(starPath.getBounds()),
    );

    canvas.drawPath(
      starPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white.withOpacity(0.55),
    );
  }

  void _drawStars(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Colors.white.withOpacity(0.75);
    final bluePaint = Paint()..color = const Color(0xFF7C8DFF);

    for (int i = 0; i < 26; i++) {
      final dx = ((i * 47 + 23) % 100) / 100 * size.width;
      final dy = ((i * 29 + 13) % 100) / 100 * size.height * 0.75;
      canvas.drawCircle(
        Offset(dx, dy),
        i % 6 == 0 ? 1.5 : 0.8,
        i % 4 == 0 ? bluePaint : starPaint,
      );
    }
  }

  Path _starPath({
    required Offset center,
    required double outerRadius,
    required double innerRadius,
    required int points,
  }) {
    final path = Path();
    final total = points * 2;

    for (int i = 0; i < total; i++) {
      final angle = -math.pi / 2 + i * math.pi / points;
      final radius = i.isEven ? outerRadius : innerRadius;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

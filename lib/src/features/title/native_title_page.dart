import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/config/environment.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/features/options/options_page.dart';
import 'package:kyouen_flutter/src/features/stage/stage_page.dart';
import 'package:kyouen_flutter/src/features/title/total_stage_count_provider.dart';
import 'package:kyouen_flutter/src/features/title/views/account_button.dart';

const _kBgTop = Color(0xFF1C2334);
const _kBgBottom = Color(0xFF0D1117);
const _kAccent = Color(0xFFFF6B35);

class TitlePage extends ConsumerWidget {
  const TitlePage({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: _TitleBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white54),
                      onPressed: () {
                        Navigator.restorablePushNamed(
                          context,
                          OptionsPage.routeName,
                        );
                      },
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                const _KyouenDiagram(),
                const SizedBox(height: 32),
                const Text(
                  Environment.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '４つの石を通る円を見つけるパズル',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 32),
                const _StageProgressDisplay(),
                const Spacer(flex: 2),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.restorablePushNamed(
                        context,
                        StagePage.routeName,
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _kBgTop,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'スタート',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AccountButton(
                  height: 52,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleBackground extends StatelessWidget {
  const _TitleBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_kBgTop, _kBgBottom],
            ),
          ),
          child: CustomPaint(
            painter: _BackgroundDecorationPainter(),
          ),
        ),
        child,
      ],
    );
  }
}

class _BackgroundDecorationPainter extends CustomPainter {
  const _BackgroundDecorationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas
      ..drawCircle(
        Offset(size.width * 0.85, size.height * 0.1),
        size.width * 0.65,
        paint,
      )
      ..drawCircle(
        Offset(size.width * 0.1, size.height * 0.82),
        size.width * 0.5,
        paint,
      )
      ..drawCircle(
        Offset(size.width * 0.5, size.height * 0.5),
        size.width * 0.85,
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated diagram: 6×6 grid with 4 stones and the kyouen circle drawn through them
class _KyouenDiagram extends StatefulWidget {
  const _KyouenDiagram();

  @override
  State<_KyouenDiagram> createState() => _KyouenDiagramState();
}

class _KyouenDiagramState extends State<_KyouenDiagram>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return CustomPaint(
                painter: _KyouenDiagramPainter(
                  animationValue: _animation.value,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _KyouenDiagramPainter extends CustomPainter {
  const _KyouenDiagramPainter({required this.animationValue});

  final double animationValue;

  static const int _boardSize = 6;

  // Stone positions (col, row) on the 6×6 grid
  // Centers in cell-unit coordinates: (1.5,1.5), (4.5,1.5), (4.5,4.5), (1.5,4.5)
  // Circle center: (3.0, 3.0) cell units
  // Circle radius: sqrt((4.5−3)²+(4.5−3)²) = sqrt(4.5) ≈ 2.121 cell units
  static const List<Offset> _stones = [
    Offset(1, 1),
    Offset(4, 1),
    Offset(4, 4),
    Offset(1, 4),
  ];
  static const Offset _circleCenter = Offset(3, 3);
  static const double _circleRadius = 2.1213135; // sqrt(4.5)

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / _boardSize;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 0.5;

    for (var i = 0; i <= _boardSize; i++) {
      canvas
        ..drawLine(
          Offset(i * cellSize, 0),
          Offset(i * cellSize, size.height),
          gridPaint,
        )
        ..drawLine(
          Offset(0, i * cellSize),
          Offset(size.width, i * cellSize),
          gridPaint,
        );
    }

    // Animated circle arc (drawn before stones so stones appear on top)
    if (animationValue > 0) {
      final cx = _circleCenter.dx * cellSize;
      final cy = _circleCenter.dy * cellSize;
      final radius = _circleRadius * cellSize;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        -math.pi / 2,
        2 * math.pi * animationValue,
        false,
        Paint()
          ..color = _kAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Stones
    for (final gridPos in _stones) {
      final cx = (gridPos.dx + 0.5) * cellSize;
      final cy = (gridPos.dy + 0.5) * cellSize;
      final r = cellSize * 0.38;

      canvas
        // Drop shadow
        ..drawCircle(
          Offset(cx + 1, cy + 2),
          r,
          Paint()
            ..color = Colors.black45
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        )
        // Stone body (warm off-white, like a Go stone)
        ..drawCircle(
          Offset(cx, cy),
          r,
          Paint()..color = const Color(0xFFF5F0E8),
        )
        // Highlight
        ..drawCircle(
          Offset(cx - r * 0.25, cy - r * 0.25),
          r * 0.28,
          Paint()..color = Colors.white.withValues(alpha: 0.65),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _KyouenDiagramPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class _StageProgressDisplay extends ConsumerWidget {
  const _StageProgressDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clearedAsync = ref.watch(clearedStageCountProvider);
    final totalAsync = ref.watch(totalStageCountProvider);

    final total = totalAsync.asData?.value ?? 0;

    return clearedAsync.when(
      loading: () => const _ProgressView(cleared: 0, total: 0, isLoading: true),
      error: (_, _) => const SizedBox.shrink(),
      data: (cleared) => _ProgressView(cleared: cleared, total: total),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView({
    required this.cleared,
    required this.total,
    this.isLoading = false,
  });

  final int cleared;
  final int total;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final progress = (total > 0) ? cleared / total : 0.0;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: isLoading ? null : progress,
            minHeight: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(_kAccent),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isLoading
              ? '読み込み中...'
              : (total > 0 ? '$cleared / $total ステージクリア' : ''),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Colors.white54),
        ),
      ],
    );
  }
}

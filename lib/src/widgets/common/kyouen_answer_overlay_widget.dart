import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kyouen/kyouen.dart';

const _kAccent = Color(0xFFFF6B35);

class KyouenAnswerOverlayWidget extends StatefulWidget {
  const KyouenAnswerOverlayWidget({
    super.key,
    required this.kyouenData,
    required this.boardSize,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  final KyouenData kyouenData;
  final int boardSize;
  final Duration animationDuration;

  @override
  State<KyouenAnswerOverlayWidget> createState() =>
      _KyouenAnswerOverlayWidgetState();
}

class _KyouenAnswerOverlayWidgetState extends State<KyouenAnswerOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: KyouenAnswerPainter(
                kyouenData: widget.kyouenData,
                boardSize: widget.boardSize,
                animationValue: _animation.value,
              ),
              child: Container(),
            );
          },
        ),
      ),
    );
  }
}

class KyouenAnswerPainter extends CustomPainter {
  const KyouenAnswerPainter({
    required this.kyouenData,
    required this.boardSize,
    required this.animationValue,
  });

  final KyouenData kyouenData;
  final int boardSize;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    // 暗めのオーバーレイで盤面を少し沈め、円を浮き立たせる
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.18 * animationValue),
    );

    final cellSize = size.width / boardSize;

    if (kyouenData.isLineKyouen) {
      _drawLine(canvas, size, cellSize);
    } else {
      _drawCircle(canvas, size, cellSize);
    }
  }

  void _drawLine(Canvas canvas, Size size, double cellSize) {
    final line = kyouenData.line;
    if (line == null) {
      return;
    }

    double startX;
    double startY;
    double stopX;
    double stopY;

    if (line.a == 0) {
      startX = 0;
      startY = line.getY(0) * cellSize + cellSize / 2;
      stopX = size.width;
      stopY = line.getY(0) * cellSize + cellSize / 2;
    } else if (line.b == 0) {
      startX = line.getX(0) * cellSize + cellSize / 2;
      startY = 0;
      stopX = line.getX(0) * cellSize + cellSize / 2;
      stopY = size.height;
    } else {
      if (-line.c / line.b > 0) {
        startX = 0;
        startY = line.getY(-0.5) * cellSize + cellSize / 2;
        stopX = size.width;
        stopY = line.getY(boardSize - 0.5) * cellSize + cellSize / 2;
      } else {
        startX = line.getX(-0.5) * cellSize + cellSize / 2;
        startY = 0;
        stopX = line.getX(boardSize - 0.5) * cellSize + cellSize / 2;
        stopY = size.height;
      }
    }

    final animatedEndX = startX + (stopX - startX) * animationValue;
    final animatedEndY = startY + (stopY - startY) * animationValue;
    final start = Offset(startX, startY);
    final end = Offset(animatedEndX, animatedEndY);

    canvas
      // グロー層
      ..drawLine(
        start,
        end,
        Paint()
          ..color = _kAccent.withValues(alpha: 0.35)
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      // 本線
      ..drawLine(
        start,
        end,
        Paint()
          ..color = _kAccent
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
  }

  void _drawCircle(Canvas canvas, Size size, double cellSize) {
    final center = kyouenData.center;
    final radius = kyouenData.radius;

    if (center == null || radius == null) {
      return;
    }

    final centerX = center.x * cellSize + cellSize / 2;
    final centerY = center.y * cellSize + cellSize / 2;
    final drawRadius = radius * cellSize;
    final sweepAngle = 2 * math.pi * animationValue;
    final rect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: drawRadius,
    );

    canvas
      // グロー層
      ..drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = _kAccent.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      // 本線
      ..drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = _kAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is KyouenAnswerPainter &&
        oldDelegate.animationValue != animationValue;
  }
}

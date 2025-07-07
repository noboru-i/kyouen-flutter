import 'package:flutter/material.dart';
import 'package:kyouen/kyouen.dart';

class KyouenAnswerOverlayWidget extends StatefulWidget {
  const KyouenAnswerOverlayWidget({
    super.key,
    required this.kyouenData,
    required this.boardSize,
    required this.isVisible,
    this.strokeWidth = 3.0,
    this.strokeColor = Colors.grey,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  final KyouenData kyouenData;
  final int boardSize;
  final bool isVisible;
  final double strokeWidth;
  final Color strokeColor;
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
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          color: Colors.transparent,
          elevation: 8,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: KyouenAnswerPainter(
                  kyouenData: widget.kyouenData,
                  boardSize: widget.boardSize,
                  strokeWidth: widget.strokeWidth,
                  strokeColor: widget.strokeColor,
                  animationValue: _animation.value,
                ),
                child: Container(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class KyouenAnswerPainter extends CustomPainter {
  const KyouenAnswerPainter({
    required this.kyouenData,
    required this.boardSize,
    required this.strokeWidth,
    required this.strokeColor,
    required this.animationValue,
  });

  final KyouenData kyouenData;
  final int boardSize;
  final double strokeWidth;
  final Color strokeColor;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = strokeColor.withValues(alpha: animationValue)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    final cellSize = size.width / boardSize;

    if (kyouenData.isLineKyouen) {
      // 直線の場合
      _drawLine(canvas, size, paint, cellSize);
    } else {
      // 円の場合
      _drawCircle(canvas, size, paint, cellSize);
    }
  }

  void _drawLine(Canvas canvas, Size size, Paint paint, double cellSize) {
    final line = kyouenData.line;
    if (line == null) {
      return;
    }

    double startX;
    double startY;
    double stopX;
    double stopY;

    if (line.a == 0) {
      // x軸と平行な場合
      startX = 0;
      startY = line.getY(0) * cellSize + cellSize / 2;
      stopX = size.width;
      stopY = line.getY(0) * cellSize + cellSize / 2;
    } else if (line.b == 0) {
      // y軸と平行な場合
      startX = line.getX(0) * cellSize + cellSize / 2;
      startY = 0;
      stopX = line.getX(0) * cellSize + cellSize / 2;
      stopY = size.height;
    } else {
      // 一般的な場合
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

    // アニメーションに応じて線の長さを調整
    final animatedEndX = startX + (stopX - startX) * animationValue;
    final animatedEndY = startY + (stopY - startY) * animationValue;

    canvas.drawLine(
      Offset(startX, startY),
      Offset(animatedEndX, animatedEndY),
      paint,
    );
  }

  void _drawCircle(Canvas canvas, Size size, Paint paint, double cellSize) {
    final center = kyouenData.center;
    final radius = kyouenData.radius;

    if (center == null || radius == null) {
      return;
    }

    final centerX = center.x * cellSize + cellSize / 2;
    final centerY = center.y * cellSize + cellSize / 2;
    final drawRadius = radius * cellSize * animationValue;

    canvas.drawCircle(Offset(centerX, centerY), drawRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is KyouenAnswerPainter &&
        oldDelegate.animationValue != animationValue;
  }
}

import 'package:flutter/material.dart';

class HintHighlightOverlayWidget extends StatefulWidget {
  const HintHighlightOverlayWidget({
    super.key,
    required this.targetIndex,
    required this.boardSize,
    this.onComplete,
    this.duration = const Duration(milliseconds: 2000),
  });

  final int targetIndex;
  final int boardSize;
  final VoidCallback? onComplete;
  final Duration duration;

  @override
  State<HintHighlightOverlayWidget> createState() =>
      _HintHighlightOverlayWidgetState();
}

class _HintHighlightOverlayWidgetState extends State<HintHighlightOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      })
      ..forward();
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
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _SpotlightPainter(
              targetIndex: widget.targetIndex,
              boardSize: widget.boardSize,
              animationValue: _controller.value,
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.targetIndex,
    required this.boardSize,
    required this.animationValue,
  });

  final int targetIndex;
  final int boardSize;
  final double animationValue;

  static const _ringColor = Color(0xFFFF6B35);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / boardSize;
    final col = targetIndex % boardSize;
    final row = targetIndex ~/ boardSize;
    final center = Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);

    // フェーズ1 (0→0.45): スポットライトが盤面全体から対象セルに絞り込む
    final phase1 = Curves.easeInOut.transform(
      (animationValue / 0.45).clamp(0.0, 1.0),
    );
    // フェーズ2 (0.35→1.0): リングが拡大しながらフェードアウト
    final phase2 = Curves.easeOut.transform(
      ((animationValue - 0.35) / 0.65).clamp(0.0, 1.0),
    );

    // スポットライトの穴のサイズ: 盤面全体 → セル1個分
    final maxRadius = size.longestSide;
    final minRadius = cellSize * 0.62;
    final spotRadius = maxRadius + (minRadius - maxRadius) * phase1;

    // オーバーレイの不透明度: フェーズ1で上がり、フェーズ2で下がる
    final overlayOpacity = (phase1 * 0.72 * (1.0 - phase2 * 0.95)).clamp(
      0.0,
      1.0,
    );

    // スポットライトオーバーレイ（穴あき矩形）
    if (overlayOpacity > 0.01) {
      final path = Path()
        ..addRect(Offset.zero & size)
        ..addOval(Rect.fromCircle(center: center, radius: spotRadius))
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(
        path,
        Paint()..color = Colors.black.withValues(alpha: overlayOpacity),
      );
    }

    // スポットライト境界のソフトグロー
    if (phase1 > 0.1 && overlayOpacity > 0.01) {
      canvas.drawCircle(
        center,
        spotRadius,
        Paint()
          ..color = _ringColor.withValues(alpha: 0.25 * overlayOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = cellSize * 0.3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    // リング（フェーズ2で拡大しながら消える）
    if (phase2 > 0) {
      final ringRadius = cellSize * (0.38 + 0.32 * phase2);
      final ringOpacity = (1.0 - phase2).clamp(0.0, 1.0);

      canvas
        ..drawCircle(
          center,
          ringRadius,
          Paint()
            ..color = _ringColor.withValues(alpha: 0.45 * ringOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = cellSize * 0.28
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        )
        ..drawCircle(
          center,
          ringRadius,
          Paint()
            ..color = _ringColor.withValues(alpha: ringOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) =>
      old.animationValue != animationValue || old.targetIndex != targetIndex;
}

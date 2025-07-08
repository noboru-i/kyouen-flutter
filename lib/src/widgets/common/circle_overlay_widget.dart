import 'package:flutter/material.dart';

class CircleOverlayWidget extends StatefulWidget {
  const CircleOverlayWidget({
    super.key,
    required this.child,
    required this.isVisible,
    this.circleColor = Colors.white,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.circleRadius = 100.0,
  });

  final Widget child;
  final bool isVisible;
  final Color circleColor;
  final Duration animationDuration;
  final double circleRadius;

  @override
  State<CircleOverlayWidget> createState() => _CircleOverlayWidgetState();
}

class _CircleOverlayWidgetState extends State<CircleOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 1,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(CircleOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isVisible)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(
                    alpha: 0.1 * _opacityAnimation.value,
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: widget.circleRadius * 2,
                        height: widget.circleRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.circleColor.withValues(alpha: 0.8),
                          border: Border.all(
                            color: widget.circleColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.circleColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

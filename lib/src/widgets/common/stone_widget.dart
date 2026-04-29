import 'package:flutter/material.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';

class StoneWidget extends StatelessWidget {
  const StoneWidget({required this.state, super.key});

  final StoneState state;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(color: Color(0xFF0B4513)),
          ),
        ),
        Align(
          child: Container(
            width: 1,
            decoration: const BoxDecoration(color: Color(0xFF0B4513)),
          ),
        ),
        Padding(padding: const EdgeInsets.all(4), child: _buildStone()),
      ],
    );
  }

  Widget _buildStone() {
    switch (state) {
      case StoneState.none:
        return const SizedBox();
      case StoneState.black:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFF4A4A4A),
                Color(0xFF1C1C1C),
                Color(0xFF000000),
              ],
              stops: [0.0, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        );
      case StoneState.white:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFE8E8E8),
                Color(0xFFD0D0D0),
              ],
              stops: [0.0, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        );
    }
  }
}

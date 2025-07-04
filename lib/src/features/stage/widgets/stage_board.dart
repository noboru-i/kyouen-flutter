import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';

class StageBoard extends ConsumerWidget {
  const StageBoard({this.stageData, this.onTapStone, super.key});

  final StageResponse? stageData;
  final void Function(int index)? onTapStone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          elevation: 8,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4CAF50), // Green
                  Color(0xFF2E7D32), // Dark Green
                ],
              ),
            ),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (stageData == null) {
      return Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator.adaptive(),
      );
    }

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: sqrt(stageData!.stage.length).toInt(),
      children: [
        for (final (index, state) in stageData!.stage.split('').indexed)
          GestureDetector(
            onTap: onTapStone != null ? () => onTapStone!(index) : null,
            child: _Stone(
              state: StoneState.fromString(state),
              key: ValueKey(index),
            ),
          ),
      ],
    );
  }
}

class _Stone extends StatelessWidget {
  const _Stone({required this.state, super.key});

  final StoneState state;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid lines
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
        // Stone
        Padding(padding: const EdgeInsets.all(4), child: _buildStone()),
      ],
    );
  }

  Widget _buildStone() {
    switch (state) {
      case StoneState.none:
        return const SizedBox();
      case StoneState.black:
        return _buildBlackStone();
      case StoneState.white:
        return _buildWhiteStone();
    }
  }

  Widget _buildBlackStone() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF4A4A4A), // Light gray
            Color(0xFF1C1C1C), // Dark gray
            Color(0xFF000000), // Black
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
  }

  Widget _buildWhiteStone() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFFFFFF), // White
            Color(0xFFE8E8E8), // Light gray
            Color(0xFFD0D0D0), // Darker gray
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

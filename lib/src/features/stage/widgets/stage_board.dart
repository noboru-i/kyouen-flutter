import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';
import 'package:kyouen_flutter/src/widgets/common/board_card_widget.dart';
import 'package:kyouen_flutter/src/widgets/common/stone_widget.dart';

class StageBoard extends ConsumerWidget {
  const StageBoard({
    this.stageData,
    this.onTapStone,
    this.overlay,
    super.key,
  });

  final StageResponse? stageData;
  final void Function(int index)? onTapStone;
  final Widget? overlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BoardCardWidget(child: _buildContent());
  }

  Widget _buildContent() {
    if (stageData == null) {
      return const Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator.adaptive(strokeWidth: 6),
        ),
      );
    }

    return Stack(
      children: [
        GridView.count(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: sqrt(stageData!.stage.length).toInt(),
          children: [
            for (final (index, state) in stageData!.stage.split('').indexed)
              GestureDetector(
                onTap: onTapStone != null ? () => onTapStone!(index) : null,
                child: StoneWidget(
                  state: StoneState.fromString(state),
                  key: ValueKey(index),
                ),
              ),
          ],
        ),
        if (overlay != null) Positioned.fill(child: overlay!),
      ],
    );
  }
}

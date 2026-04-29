import 'package:flutter/material.dart';
import 'package:kyouen/kyouen.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';
import 'package:kyouen_flutter/src/widgets/common/board_card_widget.dart';
import 'package:kyouen_flutter/src/widgets/common/kyouen_answer_overlay_widget.dart';
import 'package:kyouen_flutter/src/widgets/common/stone_widget.dart';

class CreateStageBoard extends StatelessWidget {
  const CreateStageBoard({
    super.key,
    required this.stage,
    required this.size,
    this.kyouen,
    this.onTap,
  });

  final String stage;
  final int size;
  final KyouenData? kyouen;
  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    return BoardCardWidget(
      child: Stack(
        children: [
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: size,
            children: [
              for (final (index, char) in stage.split('').indexed)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap != null ? () => onTap!(index) : null,
                  child: StoneWidget(
                    state: StoneState.fromString(char),
                    key: ValueKey(index),
                  ),
                ),
            ],
          ),
          if (kyouen != null)
            KyouenAnswerOverlayWidget(
              kyouenData: kyouen!,
              boardSize: size,
            ),
        ],
      ),
    );
  }
}

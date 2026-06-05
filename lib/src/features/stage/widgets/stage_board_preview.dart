import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:kyouen_flutter/src/features/stage/widgets/stage_board.dart';

Widget providerScopeWrapper(Widget child) => ProviderScope(child: child);

// ローディング中（stageData = null）
@Preview(name: 'Loading', wrapper: providerScopeWrapper, size: Size(300, 300))
Widget stageBoardLoading() => const StageBoard();

// 6x6ボード（一部石が配置済み）
@Preview(
  name: '6x6 - 石配置あり',
  wrapper: providerScopeWrapper,
  size: Size(360, 360),
)
Widget stageBoardWithStones() => const StageBoard(
  stageData: StageResponse(
    stageNo: 2,
    size: 6,
    // 行1: 111111, 行2: 121121, 行3: 111111, 行4: 111111, 行5: 121121, 行6: 111111
    stage: '111111121121111111111111121121111111',
    creator: 'creator',
    registDate: '2024-01-01',
  ),
);

// 9x9ボード（一部石が配置済み）
@Preview(
  name: '9x9 - 石配置あり',
  wrapper: providerScopeWrapper,
  size: Size(400, 400),
)
Widget stageBoardLarge() => const StageBoard(
  stageData: StageResponse(
    stageNo: 3,
    size: 9,
    // 行1-9: 9x9=81文字。周囲を1で囲み、中央付近に2（配置済み）を配置
    stage:
        '111111111'
        '101010101'
        '110111011'
        '101212101'
        '111121111'
        '101212101'
        '110111011'
        '101010101'
        '111111111',
    creator: 'creator',
    registDate: '2024-01-01',
  ),
);

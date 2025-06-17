import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen/kyouen.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stage_service.g.dart';

/// page starts with 1. (page 1 includes no.1 - no.10.)
@riverpod
Future<List<StageResponse>> fetchStages(Ref ref, {required int page}) {
  return ref
      .watch(apiClientProvider)
      .getStages(startStageNo: ((page - 1) * 10) + 1);
}

@riverpod
Future<StageResponse> fetchStage(Ref ref, {required int stageNo}) async {
  final page = ((stageNo - 1) / 10).floor() + 1;
  final stages = await ref.watch(fetchStagesProvider(page: page).future);
  return stages[((stageNo - 1) % 10)];
}

@riverpod
class CurrentStageNo extends _$CurrentStageNo {
  @override
  int build() {
    return 1;
  }

  void next() {
    state = state + 1;
  }

  void prev() {
    state = state - 1;
  }
}

@riverpod
class CurrentStage extends _$CurrentStage {
  @override
  Future<StageResponse> build() async {
    final currentStageNo = ref.watch(currentStageNoProvider);
    return ref.watch(fetchStageProvider(stageNo: currentStageNo).future);
  }

  void toggleSelect(int index) {
    final currentStage = state.asData!.value;
    final stage = currentStage.stage;
    final stageAsList = stage.split('');
    if (stageAsList[index] == '0') {
      return;
    }
    stageAsList[index] = stageAsList[index] == '1' ? '2' : '1';
    state = AsyncData(currentStage.copyWith(stage: stageAsList.join()));
  }

  void reset() {
    final currentStage = state.asData!.value;
    final stage = currentStage.stage;
    final stageAsList = stage.split('');
    for (var i = 0; i < stageAsList.length; i++) {
      if (stageAsList[i] == '2') {
        stageAsList[i] = '1';
      }
    }
    state = AsyncData(currentStage.copyWith(stage: stageAsList.join()));
  }

  bool isKyouen() {
    final kyouenStage = Kyouen(stonesFromString(state.asData!.value.stage));

    return kyouenStage.hasKyouen() != null;
  }
}

List<KyouenPoint> stonesFromString(String stage) {
  final size = sqrt(stage.length).toInt();
  final stoneArray = <KyouenPoint>[];
  for (var x = 0; x < size; x++) {
    for (var y = 0; y < size; y++) {
      final index = x + y * size;
      final char = stage.substring(index, index + 1);
      if (char == '2') {
        stoneArray.add(KyouenPoint(x.toDouble(), y.toDouble()));
      }
    }
  }
  return stoneArray;
}

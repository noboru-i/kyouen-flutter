import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen/kyouen.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:kyouen_flutter/src/data/local/cleared_stages_service.dart';
import 'package:kyouen_flutter/src/data/local/database.dart';
import 'package:kyouen_flutter/src/data/local/entity/tume_kyouen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stage_service.g.dart';

/// page starts with 1. (page 1 includes no.1 - no.10.)
@riverpod
Future<List<StageResponse>> fetchStages(Ref ref, {required int page}) async {
  final response = await ref
      .watch(apiClientProvider)
      .getStages(startStageNo: ((page - 1) * 10) + 1);
  return response.body ?? [];
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

  Future<void> markCurrentStageCleared() async {
    final currentStageNo = ref.read(currentStageNoProvider);
    final currentStageData = state.asData!.value;
    
    // Save or update stage data in SQLite with clear flag
    final dao = await ref.read(tumeKyouenDaoProvider.future);
    final existingStage = await dao.findStage(currentStageNo);
    
    if (existingStage == null) {
      // Insert new stage record
      final tumeKyouen = [
        TumeKyouen(
          stageNo: currentStageData.stageNo,
          size: currentStageData.size,
          stage: currentStageData.stage,
          creator: currentStageData.creator,
          clearFlag: TumeKyouen.cleared,
          clearDate: DateTime.now().millisecondsSinceEpoch,
        ),
      ];
      await dao.insertAll(tumeKyouen);
    } else {
      // Update existing record with clear flag
      await dao.clearStage(currentStageNo, DateTime.now().millisecondsSinceEpoch);
    }
    
    // Invalidate the cleared stages provider to refresh UI
    ref.invalidate(clearedStagesProvider);
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

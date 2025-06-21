import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen/kyouen.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:kyouen_flutter/src/data/database/stage_repository.dart';
import 'package:kyouen_flutter/src/data/database/stage_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stage_service.g.dart';

/// page starts with 1. (page 1 includes no.1 - no.10.)
@riverpod
Future<List<StageResponse>> fetchStages(Ref ref, {required int page}) async {
  final repository = ref.watch(stageRepositoryProvider);
  final entities = await repository.fetchAndSaveStages(
    startStageNo: ((page - 1) * 10) + 1,
  );
  return entities.map(_entityToResponse).toList();
}

@riverpod
Future<StageResponse> fetchStage(Ref ref, {required int stageNo}) async {
  final repository = ref.watch(stageRepositoryProvider);
  final entity = await repository.getStage(stageNo);
  
  if (entity == null) {
    throw Exception('Stage $stageNo not found');
  }
  
  return _entityToResponse(entity);
}

/// Check if a specific stage is cleared
@riverpod
Future<bool> isStageCleared(Ref ref, {required int stageNo}) async {
  final repository = ref.watch(stageRepositoryProvider);
  final entity = await repository.getStage(stageNo);
  return entity?.isCleared ?? false;
}

StageResponse _entityToResponse(StageEntity entity) {
  return StageResponse(
    stageNo: entity.stageNo,
    size: entity.size,
    stage: entity.stage,
    creator: entity.creator,
    registDate: '', // Note: registDate not stored in local DB
  );
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
    final updatedStage = currentStage.copyWith(stage: stageAsList.join());
    state = AsyncData(updatedStage);
    
    // Persist the stage state to database
    _saveCurrentStageState(updatedStage);
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
    final updatedStage = currentStage.copyWith(stage: stageAsList.join());
    state = AsyncData(updatedStage);
    
    // Persist the stage state to database
    _saveCurrentStageState(updatedStage);
  }

  bool isKyouen() {
    final kyouenStage = Kyouen(stonesFromString(state.asData!.value.stage));
    final hasKyouen = kyouenStage.hasKyouen() != null;
    
    // If kyouen is achieved, mark as cleared
    if (hasKyouen) {
      _markAsCleared();
    }
    
    return hasKyouen;
  }

  void _saveCurrentStageState(StageResponse stageResponse) {
    // Convert to entity and save to database
    final repository = ref.read(stageRepositoryProvider);
    final entity = StageEntity(
      stageNo: stageResponse.stageNo,
      size: stageResponse.size,
      stage: stageResponse.stage,
      creator: stageResponse.creator,
    );
    repository.updateStageState(entity);
  }

  void _markAsCleared() {
    final currentStage = state.asData!.value;
    final repository = ref.read(stageRepositoryProvider);
    repository.updateClearStatus(currentStage.stageNo, true);
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

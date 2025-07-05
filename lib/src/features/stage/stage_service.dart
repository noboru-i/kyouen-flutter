import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen/kyouen.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:kyouen_flutter/src/data/local/database.dart';
import 'package:kyouen_flutter/src/data/local/entity/tume_kyouen.dart';
import 'package:kyouen_flutter/src/data/local/preference_service.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stage_service.g.dart';

part 'stage_service.g.dart';

enum StoneState {
  none('0'), // 空
  black('1'), // 配置可能
  white('2'); // 石配置済み

  const StoneState(this.value);

  final String value;

  static StoneState fromString(String value) {
    switch (value) {
      case '0':
        return StoneState.none;
      case '1':
        return StoneState.black;
      case '2':
        return StoneState.white;
      default:
        throw ArgumentError('Invalid stone state: $value');
    }
  }
}

/// page starts with 1. (page 1 includes no.1 - no.10.)
@riverpod
Future<List<StageResponse>> fetchStages(Ref ref, {required int page}) async {
  // Fetch from API
  final response = await ref
      .watch(apiClientProvider)
      .getStages(startStageNo: ((page - 1) * 10) + 1);
  final apiStages = response.body ?? [];

  // Save all stages to SQLite for future offline access
  if (apiStages.isNotEmpty) {
    final dao = await ref.watch(tumeKyouenDaoProvider.future);
    final tumeKyouens =
        apiStages
            .map(
              (apiStage) => TumeKyouen(
                stageNo: apiStage.stageNo,
                size: apiStage.size,
                stage: apiStage.stage,
                creator: apiStage.creator,
                clearFlag: TumeKyouen.notCleared,
                clearDate: 0,
              ),
            )
            .toList();

    // Insert with REPLACE to handle duplicates
    await dao.insertAll(tumeKyouens);
  }

  return apiStages;
}

@riverpod
Future<StageResponse> fetchStage(Ref ref, {required int stageNo}) async {
  // First check if stage exists in SQLite
  final dao = await ref.watch(tumeKyouenDaoProvider.future);
  final localStage = await dao.findStage(stageNo);

  if (localStage != null) {
    // Return from SQLite if available
    return StageResponse(
      stageNo: localStage.stageNo,
      size: localStage.size,
      stage: localStage.stage,
      creator: localStage.creator,
      registDate: '', // This field isn't stored in SQLite
    );
  }

  // If not in SQLite, fetch from API and save to SQLite
  final page = ((stageNo - 1) / 10).floor() + 1;
  final stages = await ref.watch(fetchStagesProvider(page: page).future);
  final apiStage = stages[((stageNo - 1) % 10)];

  // Save to SQLite for future use
  final tumeKyouen = TumeKyouen(
    stageNo: apiStage.stageNo,
    size: apiStage.size,
    stage: apiStage.stage,
    creator: apiStage.creator,
    clearFlag: TumeKyouen.notCleared,
    clearDate: 0,
  );

  await dao.insertAll([tumeKyouen]);

  return apiStage;
}

/// Provider to get the initial stage number from preferences
final initialStageNoProvider = FutureProvider<int>((ref) async {
  try {
    final prefService = await ref.watch(preferenceServiceProvider.future);
    return prefService.getLastStageNo();
  } catch (e) {
    // Return default value if preferences fail
    return 1;
  }
});

@riverpod
class CurrentStageNo extends _$CurrentStageNo {
  @override
  int build() {
    // Start with default value of 1
    // We'll update this asynchronously when preferences are loaded
    return 1;
  }

  /// Initialize from preferences (call this when the app starts)
  Future<void> initializeFromPreferences() async {
    try {
      final prefService = await ref.read(preferenceServiceProvider.future);
      final lastStageNo = prefService.getLastStageNo();
      if (lastStageNo != state) {
        state = lastStageNo;
      }
    } catch (e) {
      // Keep default value if preferences fail
    }
  }

  /// Save the current stage number to preferences
  Future<void> _saveStageNo(int stageNo) async {
    try {
      final prefService = await ref.read(preferenceServiceProvider.future);
      await prefService.setLastStageNo(stageNo);
    } catch (e) {
      // Ignore save errors to not break the app
    }
  }

  void next() {
    final newStageNo = state + 1;
    state = newStageNo;
    _saveStageNo(newStageNo);
  }

  void prev() {
    final newStageNo = state - 1;
    if (newStageNo >= 1) {
      state = newStageNo;
      _saveStageNo(newStageNo);
    }
  }

  /// Set the current stage number directly (used for navigation)
  void setStageNo(int stageNo) {
    if (stageNo >= 1) {
      state = stageNo;
      _saveStageNo(stageNo);
    }
  }
}

@riverpod
class CurrentStage extends _$CurrentStage {
  @override
  Future<StageResponse> build() async {
    final currentStageNo = ref.watch(currentStageNoProvider);
    
    // Save the current stage number when it's accessed (matching Android behavior)
    _saveCurrentStageNo(currentStageNo);
    
    return ref.watch(fetchStageProvider(stageNo: currentStageNo).future);
  }

  /// Save the current stage number to preferences (matches Android implementation)
  Future<void> _saveCurrentStageNo(int stageNo) async {
    try {
      final prefService = await ref.read(preferenceServiceProvider.future);
      await prefService.setLastStageNo(stageNo);
    } catch (e) {
      // Ignore save errors to not break the app
    }
  }

  void toggleSelect(int index) {
    final currentStage = state.asData!.value;
    final stage = currentStage.stage;
    final stageAsList = stage.split('');
    final currentState = StoneState.fromString(stageAsList[index]);
    if (currentState == StoneState.none) {
      return;
    }
    final newState =
        currentState == StoneState.black ? StoneState.white : StoneState.black;
    stageAsList[index] = newState.value;
    state = AsyncData(currentStage.copyWith(stage: stageAsList.join()));
  }

  void reset() {
    final currentStage = state.asData!.value;
    final stage = currentStage.stage;
    final stageAsList = stage.split('');
    for (var i = 0; i < stageAsList.length; i++) {
      final currentState = StoneState.fromString(stageAsList[i]);
      if (currentState == StoneState.white) {
        stageAsList[i] = StoneState.black.value;
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

    // Since stage data is now always in SQLite (from fetchStage),
    // we only need to update the clear flag
    final dao = await ref.read(tumeKyouenDaoProvider.future);
    await dao.clearStage(currentStageNo, DateTime.now().millisecondsSinceEpoch);

    // Invalidate the cleared stages provider to refresh UI
    ref.invalidate(clearedStageNumbersProvider);
  }
}

List<KyouenPoint> stonesFromString(String stage) {
  final size = sqrt(stage.length).toInt();
  final stoneArray = <KyouenPoint>[];
  for (var x = 0; x < size; x++) {
    for (var y = 0; y < size; y++) {
      final index = x + y * size;
      final char = stage.substring(index, index + 1);
      final stoneState = StoneState.fromString(char);
      if (stoneState == StoneState.white) {
        stoneArray.add(KyouenPoint(x.toDouble(), y.toDouble()));
      }
    }
  }
  return stoneArray;
}

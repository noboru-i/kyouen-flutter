import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen/kyouen.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:kyouen_flutter/src/data/local/database.dart';
import 'package:kyouen_flutter/src/data/local/entity/tume_kyouen.dart';
import 'package:kyouen_flutter/src/data/local/last_stage_service.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stage_service.g.dart';

/// ディープリンク/URLパラメーターから読み取った初期ステージ番号。
/// アプリ起動時に ProviderScope.overrides で上書きされる。
final initialDeepLinkStageNoProvider = Provider<int?>((ref) => null);

class StageNotFoundException implements Exception {
  const StageNotFoundException(this.stageNo);
  final int stageNo;

  @override
  String toString() => 'StageNotFoundException(stageNo: $stageNo)';
}

enum StoneState {
  none('0'), // 空
  black('1'), // 配置可能
  white('2')
  ; // 石配置済み

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

@riverpod
Future<StageResponse> fetchStage(Ref ref, {required int stageNo}) async {
  // Capture dependencies synchronously before any async gap.
  final apiClient = ref.watch(apiClientProvider);
  final dao = await ref.watch(tumeKyouenDaoProvider.future);

  final localStage = await dao.findStage(stageNo);
  if (localStage != null) {
    return StageResponse(
      stageNo: localStage.stageNo,
      size: localStage.size,
      stage: localStage.stage,
      creator: localStage.creator,
      registDate: '', // This field isn't stored in SQLite
    );
  }

  // Fetch the containing page from API and cache all stages in the page.
  final page = ((stageNo - 1) / 10).floor() + 1;
  final response = await apiClient.getStages(
    startStageNo: ((page - 1) * 10) + 1,
  );
  final apiStages = response.body ?? [];

  StageResponse? apiStage;
  for (final s in apiStages) {
    if (s.stageNo == stageNo) {
      apiStage = s;
      break;
    }
  }
  if (apiStage == null) {
    throw StageNotFoundException(stageNo);
  }

  final tumeKyouens = apiStages
      .map(
        (s) => TumeKyouen(
          stageNo: s.stageNo,
          size: s.size,
          stage: s.stage,
          creator: s.creator,
          clearFlag: TumeKyouen.notCleared,
          clearDate: 0,
        ),
      )
      .toList();
  await dao.insertOrUpdateStages(tumeKyouens);

  // Reflect server-side clear status for stages the user has already cleared.
  final clearDateByStageNo = <int, int>{};
  for (final s in apiStages) {
    if (s.clearDate != null) {
      clearDateByStageNo[s.stageNo] = DateTime.parse(
        s.clearDate!,
      ).millisecondsSinceEpoch;
    }
  }
  if (clearDateByStageNo.isNotEmpty) {
    await dao.updateClearStatuses(clearDateByStageNo);
    if (ref.mounted) {
      ref
        ..invalidate(clearedStageNumbersProvider)
        ..invalidate(clearedStageCountProvider);
    }
  }

  return apiStage;
}

@riverpod
LastStageService lastStageService(Ref ref) {
  return LastStageService();
}

@riverpod
class CurrentStageNo extends _$CurrentStageNo {
  @override
  Future<int> build() async {
    final deepLinkStageNo = ref.read(initialDeepLinkStageNoProvider);
    if (deepLinkStageNo != null) {
      return deepLinkStageNo;
    }
    final lastStageService = ref.read(lastStageServiceProvider);
    final lastStageNo = await lastStageService.getLastStageNo();
    return lastStageNo ?? 1;
  }

  Future<void> _saveCurrentStageNo(int stageNo) async {
    final lastStageService = ref.read(lastStageServiceProvider);
    await lastStageService.saveLastStageNo(stageNo);
  }

  Future<bool> next() async {
    final currentState = state;
    if (currentState is! AsyncData<int>) {
      return false;
    }
    final newValue = currentState.value + 1;

    final repository = await ref.read(stageRepositoryProvider.future);
    if (!await repository.stageExists(newValue)) {
      return false;
    }

    // stageExists may have fetched a new page from the API and updated clear
    // statuses in SQLite. Invalidate so the UI reflects the latest DB state.
    ref
      ..invalidate(clearedStageNumbersProvider)
      ..invalidate(clearedStageCountProvider);

    state = AsyncData(newValue);
    await _saveCurrentStageNo(newValue);
    return true;
  }

  Future<void> prev() async {
    final currentState = state;
    if (currentState is AsyncData<int> && currentState.value > 1) {
      final newValue = currentState.value - 1;
      state = AsyncData(newValue);
      await _saveCurrentStageNo(newValue);
    }
  }

  Future<void> setStageNo(int stageNo) async {
    if (stageNo > 0) {
      state = AsyncData(stageNo);
      await _saveCurrentStageNo(stageNo);
    }
  }
}

@riverpod
class CurrentStage extends _$CurrentStage {
  @override
  Future<StageResponse> build() async {
    final currentStageNoAsync = ref.watch(currentStageNoProvider);
    final currentStageNo = currentStageNoAsync.when(
      data: (stageNo) => stageNo,
      loading: () => 1,
      error: (_, _) => 1,
    );
    return ref.watch(fetchStageProvider(stageNo: currentStageNo).future);
  }

  void toggleSelect(int index) {
    final currentStage = state.asData!.value;
    final stage = currentStage.stage;
    final stageAsList = stage.split('');
    final currentState = StoneState.fromString(stageAsList[index]);
    if (currentState == StoneState.none) {
      return;
    }
    final newState = currentState == StoneState.black
        ? StoneState.white
        : StoneState.black;
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

  KyouenData? getKyouenData() {
    final kyouenStage = Kyouen(stonesFromString(state.asData!.value.stage));
    return kyouenStage.hasKyouen();
  }

  Future<void> markCurrentStageCleared() async {
    final currentStageNoAsync = ref.read(currentStageNoProvider);
    final currentStageNo = currentStageNoAsync.when(
      data: (stageNo) => stageNo,
      loading: () => 1,
      error: (_, _) => 1,
    );

    // Get the current stage state (user's solution)
    final currentStageState = state.asData!.value.stage;

    final stageRepository = await ref.read(stageRepositoryProvider.future);
    await stageRepository.clearStage(currentStageNo, currentStageState);

    ref
      ..invalidate(clearedStageNumbersProvider)
      ..invalidate(clearedStageCountProvider);
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

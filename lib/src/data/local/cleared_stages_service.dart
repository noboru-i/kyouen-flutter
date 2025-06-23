import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/local/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cleared_stages_service.g.dart';

@riverpod
ClearedStagesService clearedStagesService(Ref ref) {
  return ClearedStagesService(ref);
}

@riverpod
Future<Set<int>> clearedStages(Ref ref) {
  final service = ref.watch(clearedStagesServiceProvider);
  return service.getClearedStages();
}

class ClearedStagesService {
  const ClearedStagesService(this._ref);

  final Ref _ref;

  /// Get all cleared stage numbers from SQLite
  Future<Set<int>> getClearedStages() async {
    final dao = await _ref.read(tumeKyouenDaoProvider.future);
    final clearedStages = await dao.selectAllClearStage();
    return clearedStages.map((stage) => stage.stageNo).toSet();
  }

  /// Mark a stage as cleared in SQLite
  Future<void> markStageCleared(int stageNo) async {
    final dao = await _ref.read(tumeKyouenDaoProvider.future);
    final clearDate = DateTime.now().millisecondsSinceEpoch;
    await dao.clearStage(stageNo, clearDate);
  }

  /// Check if a specific stage is cleared
  Future<bool> isStageCleared(int stageNo) async {
    final cleared = await getClearedStages();
    return cleared.contains(stageNo);
  }

  /// Get stage count statistics
  Future<Map<String, int>> getStageCount() async {
    final dao = await _ref.read(tumeKyouenDaoProvider.future);
    return dao.selectStageCount();
  }
}

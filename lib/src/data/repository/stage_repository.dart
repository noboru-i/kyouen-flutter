import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/clear_stage.dart';
import 'package:kyouen_flutter/src/data/api/entity/cleared_stage.dart';
import 'package:kyouen_flutter/src/data/api/entity/new_stage.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:kyouen_flutter/src/data/local/dao/tume_kyouen_dao.dart';
import 'package:kyouen_flutter/src/data/local/database.dart';
import 'package:kyouen_flutter/src/data/local/entity/tume_kyouen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stage_repository.g.dart';

@riverpod
Future<StageRepository> stageRepository(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final dao = await ref.watch(tumeKyouenDaoProvider.future);
  return StageRepository(apiClient, dao);
}

@riverpod
Future<Set<int>> clearedStageNumbers(Ref ref) async {
  final repository = await ref.watch(stageRepositoryProvider.future);
  return repository.getClearedStageNumbers();
}

class StageRepository {
  const StageRepository(this._apiClient, this._dao);

  final ApiClient _apiClient;
  final TumeKyouenDao _dao;

  Future<List<StageResponse>> getStages({
    int startStageNo = 1,
    int? limit,
  }) async {
    final response = await _apiClient.getStages(
      startStageNo: startStageNo,
      limit: limit,
    );

    if (response.isSuccessful && response.body != null) {
      // Save to local database
      final tumeKyouens =
          response.body!
              .map(
                (stage) => TumeKyouen(
                  stageNo: stage.stageNo,
                  size: stage.size,
                  stage: stage.stage,
                  creator: stage.creator,
                  clearFlag: TumeKyouen.notCleared,
                  clearDate: 0,
                ),
              )
              .toList();

      await _dao.insertAll(tumeKyouens);
      return response.body!;
    }

    throw Exception('Failed to get stages: ${response.error}');
  }

  Future<StageResponse> createStage(NewStage newStage) async {
    final response = await _apiClient.createStage(newStage);

    if (response.isSuccessful && response.body != null) {
      // Save to local database
      final tumeKyouen = TumeKyouen(
        stageNo: response.body!.stageNo,
        size: response.body!.size,
        stage: response.body!.stage,
        creator: response.body!.creator,
        clearFlag: TumeKyouen.notCleared,
        clearDate: 0,
      );

      await _dao.insertAll([tumeKyouen]);
      return response.body!;
    }

    throw Exception('Failed to create stage: ${response.error}');
  }

  Future<void> clearStage(int stageNo) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final clearStage = ClearStage(clearDate: DateTime.now().toIso8601String());

    await _apiClient.clearStage(stageNo, clearStage);

    // Always update local database even if API call fails
    await _dao.clearStage(stageNo, now);
  }

  Future<List<ClearedStage>> syncStages() async {
    final clearedStages = await _dao.selectAllClearStage();
    final clearedStageRequests =
        clearedStages
            .map(
              (stage) => ClearedStage(
                stageNo: stage.stageNo,
                clearDate:
                    DateTime.fromMillisecondsSinceEpoch(
                      stage.clearDate,
                    ).toIso8601String(),
              ),
            )
            .toList();

    final response = await _apiClient.syncStages(clearedStageRequests);

    if (response.isSuccessful && response.body != null) {
      return response.body!;
    }

    throw Exception('Failed to sync stages: ${response.error}');
  }

  // Local database operations
  Future<TumeKyouen?> findLocalStage(int stageNo) {
    return _dao.findStage(stageNo);
  }

  Future<int> getMaxStageNo() {
    return _dao.selectMaxStageNo();
  }

  Future<Map<String, int>> getStageCount() {
    return _dao.selectStageCount();
  }

  Future<List<TumeKyouen>> getAllClearedStages() {
    return _dao.selectAllClearStage();
  }

  // Cleared stages management methods
  Future<Set<int>> getClearedStageNumbers() async {
    final clearedStages = await _dao.selectAllClearStage();
    return clearedStages.map((stage) => stage.stageNo).toSet();
  }

  Future<bool> isStageCleared(int stageNo) async {
    final cleared = await getClearedStageNumbers();
    return cleared.contains(stageNo);
  }

  Future<void> markStageCleared(int stageNo) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.clearStage(stageNo, now);
  }
}

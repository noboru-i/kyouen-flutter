import 'dart:async';

import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/clear_stage.dart';
import 'package:kyouen_flutter/src/data/api/entity/cleared_stage.dart';
import 'package:kyouen_flutter/src/data/api/entity/new_stage.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:kyouen_flutter/src/data/local/cleared_stage_count_service.dart';
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

@riverpod
Future<int> clearedStageCount(Ref ref) async {
  final repository = await ref.watch(stageRepositoryProvider.future);
  return repository.getClearedCount();
}

class StageRepository {
  StageRepository(this._apiClient, this._dao);

  final ApiClient _apiClient;
  final TumeKyouenDao _dao;
  final _clearedCountService = ClearedStageCountService();

  Future<List<StageResponse>> getStages({
    int startStageNo = 1,
    int limit = 100,
  }) async {
    final response = await _apiClient.getStages(
      startStageNo: startStageNo,
      limit: limit,
    );

    if (response.isSuccessful && response.body != null) {
      final stages = response.body!;
      final tumeKyouens = stages
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

      await _dao.insertOrUpdateStages(tumeKyouens);

      // Reflect server-side clear status for stages the user has already cleared.
      final clearDateByStageNo = <int, int>{};
      for (final stage in stages) {
        if (stage.clearDate != null) {
          clearDateByStageNo[stage.stageNo] = DateTime.parse(
            stage.clearDate!,
          ).millisecondsSinceEpoch;
        }
      }
      if (clearDateByStageNo.isNotEmpty) {
        await _dao.updateClearStatuses(clearDateByStageNo);
      }

      return stages;
    }

    throw Exception('Failed to get stages: ${response.error}');
  }

  Future<StageResponse> createStage(NewStage newStage) async {
    final response = await _apiClient.createStage(newStage);

    if (response.isSuccessful && response.body != null) {
      final tumeKyouen = TumeKyouen(
        stageNo: response.body!.stageNo,
        size: response.body!.size,
        stage: response.body!.stage,
        creator: response.body!.creator,
        clearFlag: TumeKyouen.notCleared,
        clearDate: 0,
      );

      await _dao.insertOrUpdateStages([tumeKyouen]);
      return response.body!;
    }

    throw Exception('Failed to create stage: ${response.error}');
  }

  Future<void> clearStage(int stageNo, String userStage) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Local DB operations first so the caller is not blocked by the network.
    final existing = await _dao.findStage(stageNo);
    if (existing?.clearFlag != TumeKyouen.cleared) {
      await _clearedCountService.increment();
    }
    await _dao.clearStage(stageNo, now);

    // Fire-and-forget: sync to server without blocking the UI.
    final clearStageRequest = ClearStage(
      stage: userStage,
      clearDate: DateTime.now().toUtc().toIso8601String(),
    );
    unawaited(
      _apiClient
          .clearStage(stageNo, clearStageRequest)
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  /// Sends locally cleared stages to server and updates local DB with the
  /// server's merged cleared-stage list.
  Future<void> syncStages() async {
    final clearedStages = await _dao.selectAllClearStage();
    final clearedStageRequests = clearedStages
        .map(
          (stage) => ClearedStage(
            stageNo: stage.stageNo,
            clearDate: DateTime.fromMillisecondsSinceEpoch(
              stage.clearDate,
              isUtc: true,
            ).toIso8601String(),
          ),
        )
        .toList();

    final response = await _apiClient.syncStages(clearedStageRequests);

    if (response.isSuccessful && response.body != null) {
      final clearDateByStageNo = <int, int>{};
      for (final cleared in response.body!) {
        final clearDateMs = DateTime.parse(
          cleared.clearDate,
        ).millisecondsSinceEpoch;
        clearDateByStageNo[cleared.stageNo] = clearDateMs;
      }
      if (clearDateByStageNo.isNotEmpty) {
        await _dao.updateClearStatuses(clearDateByStageNo);
      }
      // Server is authoritative: save the exact cleared count it returned.
      await _clearedCountService.saveCount(response.body!.length);
      return;
    }

    throw Exception('Failed to sync stages: ${response.error}');
  }

  /// Returns the cleared stage count from SharedPreferences.
  /// On first call (before any sync or clear), seeds from local SQLite so
  /// existing users see a sensible value immediately after an app update.
  Future<int> getClearedCount() async {
    final raw = await _clearedCountService.getRawCount();
    if (raw == null) {
      final counts = await _dao.selectStageCount();
      final localCleared = counts['clear_count'] ?? 0;
      await _clearedCountService.saveCount(localCleared);
      return localCleared;
    }
    return raw;
  }

  // Local database operations
  Future<TumeKyouen?> findLocalStage(int stageNo) {
    return _dao.findStage(stageNo);
  }

  Future<int> getMaxStageNo() {
    return _dao.selectMaxStageNo();
  }

  Future<List<TumeKyouen>> getAllClearedStages() {
    return _dao.selectAllClearStage();
  }

  Future<Set<int>> getClearedStageNumbers() async {
    final clearedStages = await _dao.selectAllClearStage();
    return clearedStages.map((stage) => stage.stageNo).toSet();
  }

  Future<bool> isStageCleared(int stageNo) async {
    final cleared = await getClearedStageNumbers();
    return cleared.contains(stageNo);
  }

  /// Returns whether [stageNo] exists locally or on the server.
  ///
  /// If not cached locally, fetches the containing page from the API,
  /// persisting it to SQLite as a side effect so subsequent reads are fast.
  Future<bool> stageExists(int stageNo) async {
    final local = await _dao.findStage(stageNo);
    if (local != null) {
      return true;
    }

    final startStageNo = ((stageNo - 1) ~/ 10) * 10 + 1;
    final pageStages = await getStages(startStageNo: startStageNo);
    return pageStages.any((s) => s.stageNo == stageNo);
  }

  Future<void> resetClearData() async {
    await _dao.resetAllClearStatuses();
    await _clearedCountService.saveCount(0);
  }

  Future<void> markStageCleared(int stageNo) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.clearStage(stageNo, now);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'database_service.dart';
import 'stage_entity.dart';

part 'stage_repository.g.dart';

@riverpod
StageRepository stageRepository(Ref ref) {
  return StageRepository(
    apiClient: ref.watch(apiClientProvider),
    databaseService: ref.watch(databaseServiceProvider),
  );
}

class StageRepository {
  const StageRepository({
    required this.apiClient,
    required this.databaseService,
  });

  final ApiClient apiClient;
  final DatabaseService databaseService;

  /// Fetch stages from API and save to database
  Future<List<StageEntity>> fetchAndSaveStages({required int startStageNo}) async {
    try {
      final response = await apiClient.getStages(startStageNo: startStageNo);
      final apiStages = response.body ?? [];
      
      final stages = apiStages.map((apiStage) => _stageResponseToEntity(apiStage)).toList();
      
      // Save to database
      for (final stage in stages) {
        await databaseService.insertStage(stage);
      }
      
      return stages;
    } catch (e) {
      // If API fails, try to get from local database
      return await getLocalStages(startStageNo: startStageNo, limit: 10);
    }
  }

  /// Get stages from local database
  Future<List<StageEntity>> getLocalStages({int? startStageNo, int? limit}) async {
    return await databaseService.getStages(
      startStageNo: startStageNo,
      limit: limit,
    );
  }

  /// Get specific stage from database, fetch from API if not found
  Future<StageEntity?> getStage(int stageNo) async {
    // Try local database first
    StageEntity? stage = await databaseService.getStage(stageNo);
    
    if (stage == null) {
      // If not found locally, fetch from API
      try {
        final page = ((stageNo - 1) / 10).floor() + 1;
        final stages = await fetchAndSaveStages(startStageNo: ((page - 1) * 10) + 1);
        stage = stages.firstWhere(
          (s) => s.stageNo == stageNo,
          orElse: () => throw Exception('Stage $stageNo not found'),
        );
      } catch (e) {
        return null;
      }
    }
    
    return stage;
  }

  /// Update stage state (for gameplay modifications)
  Future<void> updateStageState(StageEntity stage) async {
    await databaseService.updateStage(stage);
  }

  /// Mark stage as cleared or uncleared
  Future<void> updateClearStatus(int stageNo, bool isCleared) async {
    await databaseService.updateClearStatus(stageNo, isCleared);
  }

  StageEntity _stageResponseToEntity(StageResponse response) {
    return StageEntity(
      stageNo: response.stageNo,
      size: response.size,
      stage: response.stage,
      creator: response.creator,
      clearFlag: 0, // Default to not cleared
      clearDate: 0, // Default to no clear date
    );
  }
}
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stage_service.g.dart';

/// page starts with 1. (page 1 includes no.1 - no.10.)
@riverpod
Future<List<StageResponse>> fetchStages(
  FetchStagesRef ref, {
  required int page,
}) async {
  return ref
      .watch(apiClientProvider)
      .getStages(startStageNo: ((page - 1) * 10) + 1);
}

@riverpod
Future<StageResponse> fetchStage(
  FetchStageRef ref, {
  required int stageNo,
}) async {
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
Future<StageResponse> currentStage(CurrentStageRef ref) async {
  final currentStageNo = ref.watch(currentStageNoProvider);
  return ref.watch(fetchStageProvider(stageNo: currentStageNo).future);
}

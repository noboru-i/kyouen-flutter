import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/activity_user.dart';
import 'package:kyouen_flutter/src/data/api/entity/recent_stage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'web_title_repository.g.dart';

@riverpod
Future<List<RecentStage>> recentStages(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.getRecentStages();

  if (response.isSuccessful && response.body != null) {
    return response.body!;
  } else {
    throw Exception('Failed to fetch recent stages');
  }
}

@riverpod
Future<List<ActivityUser>> activities(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.getActivities();

  if (response.isSuccessful && response.body != null) {
    return response.body!;
  } else {
    throw Exception('Failed to fetch activities');
  }
}

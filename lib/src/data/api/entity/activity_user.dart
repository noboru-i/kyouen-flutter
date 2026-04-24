import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_user.freezed.dart';
part 'activity_user.g.dart';

@freezed
abstract class ActivityUser with _$ActivityUser {
  const factory ActivityUser({
    required String screenName,
    required String image,
    required List<ClearedStageActivity> clearedStages,
  }) = _ActivityUser;

  factory ActivityUser.fromJson(Map<String, dynamic> json) =>
      _$ActivityUserFromJson(json);
}

@freezed
abstract class ClearedStageActivity with _$ClearedStageActivity {
  const factory ClearedStageActivity({
    required int stageNo,
    required String clearDate,
  }) = _ClearedStageActivity;

  factory ClearedStageActivity.fromJson(Map<String, dynamic> json) =>
      _$ClearedStageActivityFromJson(json);
}

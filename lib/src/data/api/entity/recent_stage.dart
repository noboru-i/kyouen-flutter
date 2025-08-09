import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_stage.freezed.dart';
part 'recent_stage.g.dart';

@freezed
abstract class RecentStage with _$RecentStage {
  const factory RecentStage({
    required int stageNo,
    required int size,
    required String stage,
    required String creator,
    required String registDate,
  }) = _RecentStage;

  factory RecentStage.fromJson(Map<String, dynamic> json) =>
      _$RecentStageFromJson(json);
}

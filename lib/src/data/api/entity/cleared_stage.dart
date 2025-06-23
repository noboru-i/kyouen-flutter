import 'package:freezed_annotation/freezed_annotation.dart';

part 'cleared_stage.freezed.dart';
part 'cleared_stage.g.dart';

@freezed
abstract class ClearedStage with _$ClearedStage {
  const factory ClearedStage({
    required int stageNo,
    required String clearDate,
  }) = _ClearedStage;

  factory ClearedStage.fromJson(Map<String, Object?> json) =>
      _$ClearedStageFromJson(json);
}

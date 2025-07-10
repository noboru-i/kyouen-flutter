import 'package:freezed_annotation/freezed_annotation.dart';

part 'clear_stage.freezed.dart';
part 'clear_stage.g.dart';

@freezed
abstract class ClearStage with _$ClearStage {
  const factory ClearStage({required String stage, required String clearDate}) =
      _ClearStage;

  factory ClearStage.fromJson(Map<String, Object?> json) =>
      _$ClearStageFromJson(json);
}

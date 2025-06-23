import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_stage.freezed.dart';
part 'new_stage.g.dart';

@freezed
abstract class NewStage with _$NewStage {
  const factory NewStage({
    required int size,
    required String stage,
    required String creator,
  }) = _NewStage;

  factory NewStage.fromJson(Map<String, Object?> json) =>
      _$NewStageFromJson(json);
}
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stage_response.freezed.dart';
part 'stage_response.g.dart';

@freezed
class StageResponse with _$StageResponse {
  const factory StageResponse({
    required int stageNo,
    required int size,
    required String stage,
    required String creator,
    required String registDate,
  }) = _StageResponse;

  factory StageResponse.fromJson(Map<String, Object?> json) =>
      _$StageResponseFromJson(json);
}

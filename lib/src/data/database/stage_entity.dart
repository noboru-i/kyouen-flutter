import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stage_entity.freezed.dart';
part 'stage_entity.g.dart';

@freezed
abstract class StageEntity with _$StageEntity {
  const factory StageEntity({
    int? uid,
    required int stageNo,
    required int size,
    required String stage,
    required String creator,
    @Default(0) int clearFlag,
    @Default(0) int clearDate,
  }) = _StageEntity;

  factory StageEntity.fromJson(Map<String, Object?> json) =>
      _$StageEntityFromJson(json);

  factory StageEntity.fromMap(Map<String, dynamic> map) {
    return StageEntity(
      uid: map['uid'] as int?,
      stageNo: map['stage_no'] as int,
      size: map['size'] as int,
      stage: map['stage'] as String,
      creator: map['creator'] as String,
      clearFlag: map['clear_flag'] as int? ?? 0,
      clearDate: map['clear_date'] as int? ?? 0,
    );
  }
}

extension StageEntityExtension on StageEntity {
  Map<String, dynamic> toMap() {
    return {
      if (uid != null) 'uid': uid,
      'stage_no': stageNo,
      'size': size,
      'stage': stage,
      'creator': creator,
      'clear_flag': clearFlag,
      'clear_date': clearDate,
    };
  }

  bool get isCleared => clearFlag == 1;
}
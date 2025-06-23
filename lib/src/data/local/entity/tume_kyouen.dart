import 'package:freezed_annotation/freezed_annotation.dart';

part 'tume_kyouen.freezed.dart';
part 'tume_kyouen.g.dart';

@freezed
abstract class TumeKyouen with _$TumeKyouen {
  const factory TumeKyouen({
    int? uid,
    required int stageNo,
    required int size,
    required String stage,
    required String creator,
    required int clearFlag,
    required int clearDate,
  }) = _TumeKyouen;

  factory TumeKyouen.fromJson(Map<String, Object?> json) =>
      _$TumeKyouenFromJson(json);

  static const tableName = 'tume_kyouen';
  static const cleared = 1;
  static const notCleared = 0;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'statics.freezed.dart';
part 'statics.g.dart';

@freezed
abstract class Statics with _$Statics {
  const factory Statics({
    required int count,
  }) = _Statics;

  factory Statics.fromJson(Map<String, dynamic> json) =>
      _$StaticsFromJson(json);
}

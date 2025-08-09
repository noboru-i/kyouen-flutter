import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource_error.g.dart';

@JsonSerializable()
class ResourceError {
  ResourceError(this.type, this.message);

  static const ResourceError Function(Map<String, dynamic>) fromJson =
      _$ResourceErrorFromJson;

  final String type;
  final String message;

  Map<String, dynamic> toJson() => _$ResourceErrorToJson(this);
}

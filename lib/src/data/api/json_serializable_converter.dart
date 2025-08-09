import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:kyouen_flutter/src/data/api/entity/resource_error.dart';

// copy from https://github.com/lejard-h/chopper/blob/415c04f3d190c70eac47f87c3afdcd5fdecdbc98/example/bin/main_json_serializable.dart#L74-L128

typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

class JsonSerializableConverter extends JsonConverter {
  const JsonSerializableConverter(this.factories);

  final Map<Type, JsonFactory<dynamic>> factories;

  T? _decodeMap<T>(Map<String, dynamic> values) {
    /// Get jsonFactory using Type parameters
    /// if not found or invalid, throw error or return null
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! JsonFactory<T>) {
      /// throw serializer not found error;
      return null;
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable<dynamic> values) =>
      values.where((v) => v != null).map<T>((v) => _decode<T>(v) as T).toList();

  dynamic _decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity as List);
    } else if (entity is Map) {
      return _decodeMap<T>(entity as Map<String, dynamic>);
    }

    return entity;
  }

  @override
  FutureOr<Response<ResultType>> convertResponse<ResultType, Item>(
    Response<dynamic> response,
  ) async {
    // use [JsonConverter] to decode json
    final jsonRes = await super.convertResponse<dynamic, dynamic>(response);

    return jsonRes.copyWith<ResultType>(
      body: _decode<Item>(jsonRes.body) as ResultType?,
    );
  }

  @override
  // all objects should implements toJson method
  // ignore: unnecessary_overrides
  Request convertRequest(Request request) => super.convertRequest(request);

  @override
  FutureOr<Response<dynamic>> convertError<ResultType, Item>(
    Response<dynamic> response,
  ) async {
    // use [JsonConverter] to decode json
    final jsonRes = await super.convertError<dynamic, dynamic>(response);

    return jsonRes.copyWith<ResourceError>(
      body: ResourceError.fromJsonFactory(jsonRes.body as Map<String, dynamic>),
    );
  }
}

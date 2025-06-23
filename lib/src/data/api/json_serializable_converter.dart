import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:kyouen_flutter/src/data/api/entity/login_response.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';

class JsonSerializableConverter extends JsonConverter {
  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(
    Response<dynamic> response,
  ) {
    return response.copyWith<BodyType>(
      body: fromJsonData<BodyType, InnerType>(
        response.body as String,
        response.base.request!.url.path,
      ),
    );
  }

  T fromJsonData<T, InnerType>(String jsonData, String url) {
    final jsonMap = jsonDecode(jsonData);

    if (jsonMap is List) {
      return _convertList<T, InnerType>(jsonMap);
    } else if (jsonMap is Map<String, dynamic>) {
      return _convertSingle<T>(jsonMap, url);
    }

    return jsonMap as T;
  }

  T _convertList<T, InnerType>(List<dynamic> jsonList) {
    if (InnerType == StageResponse) {
      return jsonList
              .map(
                (item) => StageResponse.fromJson(item as Map<String, dynamic>),
              )
              .toList()
          as T;
    }

    return jsonList as T;
  }

  T _convertSingle<T>(Map<String, dynamic> jsonMap, String url) {
    if (T == LoginResponse || url.contains('/users/login')) {
      return LoginResponse.fromJson(jsonMap) as T;
    } else if (T == StageResponse || url.contains('/stages')) {
      return StageResponse.fromJson(jsonMap) as T;
    }

    return jsonMap as T;
  }
}

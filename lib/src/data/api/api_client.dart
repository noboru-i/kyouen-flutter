import 'package:chopper/chopper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/config/environment.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.chopper.dart';
part 'api_client.g.dart';

@ChopperApi(baseUrl: '/')
abstract class ApiClient extends ChopperService {
  static ApiClient create([ChopperClient? client]) =>
      _$ApiClient(client);

  @GET(path: '/stages')
  Future<Response<List<StageResponse>>> getStages({
    @Query('start_stage_no') int startStageNo = 1,
  });
}

@riverpod
ApiClient apiClient(Ref ref) {
  final client = ChopperClient(
    baseUrl: Uri.parse(Environment.apiBaseUrl),
    services: [
      ApiClient.create(),
    ],
    converter: const JsonConverter(),
    interceptors: [
      HttpLoggingInterceptor(),
    ],
  );
  return ApiClient.create(client);
}

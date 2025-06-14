import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: 'https://kyouen.app/v2/')
// ignore: one_member_abstracts
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET('/stages')
  Future<List<StageResponse>> getStages({
    @Query('start_stage_no') int startStageNo = 1,
  });
}

@riverpod
ApiClient apiClient(Ref ref) {
  final dio = Dio();
  dio.interceptors.add(LogInterceptor(responseBody: true));
  return ApiClient(dio);
}

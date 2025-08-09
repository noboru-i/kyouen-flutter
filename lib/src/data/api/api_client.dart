import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/config/environment.dart';
import 'package:kyouen_flutter/src/data/api/entity/activity_user.dart';
import 'package:kyouen_flutter/src/data/api/entity/clear_stage.dart';
import 'package:kyouen_flutter/src/data/api/entity/cleared_stage.dart';
import 'package:kyouen_flutter/src/data/api/entity/login_request.dart';
import 'package:kyouen_flutter/src/data/api/entity/login_response.dart';
import 'package:kyouen_flutter/src/data/api/entity/new_stage.dart';
import 'package:kyouen_flutter/src/data/api/entity/recent_stage.dart';
import 'package:kyouen_flutter/src/data/api/entity/resource_error.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:kyouen_flutter/src/data/api/firebase_auth_interceptor.dart';
import 'package:kyouen_flutter/src/data/api/json_serializable_converter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.chopper.dart';
part 'api_client.g.dart';

@ChopperApi(baseUrl: '/')
abstract class ApiClient extends ChopperService {
  static ApiClient create([ChopperClient? client]) => _$ApiClient(client);

  @GET(path: '/stages')
  Future<Response<List<StageResponse>>> getStages({
    @Query('start_stage_no') int startStageNo = 1,
    @Query('limit') int? limit,
  });

  @POST(path: '/users/login')
  Future<Response<LoginResponse>> login(@Body() LoginRequest request);

  @POST(path: '/stages')
  Future<Response<StageResponse>> createStage(@Body() NewStage newStage);

  @PUT(path: '/stages/{stageNo}/clear')
  Future<Response<void>> clearStage(
    @Path('stageNo') int stageNo,
    @Body() ClearStage clearStage,
  );

  @POST(path: '/stages/sync')
  Future<Response<List<ClearedStage>>> syncStages(
    @Body() List<ClearedStage> clearedStages,
  );

  @GET(path: '/recent_stages')
  Future<Response<List<RecentStage>>> getRecentStages();

  @GET(path: '/activities')
  Future<Response<List<ActivityUser>>> getActivities();

  @DELETE(path: '/users/delete-account')
  Future<Response<void>> deleteAccount();
}

@riverpod
ApiClient apiClient(Ref ref) {
  final client = ChopperClient(
    baseUrl: Uri.parse(Environment.apiBaseUrl),
    services: [ApiClient.create()],
    converter: const JsonSerializableConverter({
      ActivityUser: ActivityUser.fromJson,
      ClearedStage: ClearedStage.fromJson,
      LoginResponse: LoginResponse.fromJson,
      RecentStage: RecentStage.fromJson,
      StageResponse: StageResponse.fromJson,
      ResourceError: ResourceError.fromJson,
    }),
    interceptors: [
      FirebaseAuthInterceptor(),
      if (kDebugMode) HttpLoggingInterceptor(),
    ],
  );
  return ApiClient.create(client);
}

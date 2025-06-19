// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ApiClient extends ApiClient {
  _$ApiClient([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ApiClient;

  @override
  Future<Response<List<StageResponse>>> getStages({int startStageNo = 1}) {
    final Uri $url = Uri.parse('/stages');
    final Map<String, dynamic> $params = <String, dynamic>{
      'start_stage_no': startStageNo,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<StageResponse>, StageResponse>($request);
  }
}

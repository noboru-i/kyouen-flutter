import 'dart:async';

import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/local/total_stage_count_service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'total_stage_count_provider.g.dart';

final _logger = Logger();

@riverpod
class TotalStageCount extends _$TotalStageCount {
  final _service = TotalStageCountService();

  @override
  Future<int> build() async {
    final cached = await _service.getCachedTotalCount();
    // キャッシュを返した後、バックグラウンドで最新値を取得する
    unawaited(Future.microtask(_refreshFromApi));
    return cached ?? 0;
  }

  Future<void> _refreshFromApi() async {
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.getStatics();
      final count = response.body?.count;
      if (count != null) {
        state = AsyncData(count);
        await _service.saveTotalCount(count);
      }
    } on Exception catch (e, stack) {
      _logger.w('Failed to fetch statics count', error: e, stackTrace: stack);
      // キャッシュ値のまま維持するため state は更新しない
    }
  }
}

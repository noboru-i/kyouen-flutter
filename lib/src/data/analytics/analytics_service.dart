import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService._(),
);

class AnalyticsService {
  AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> setConsent({
    required bool analyticsStorage,
    required bool adStorage,
  }) => _analytics.setConsent(
    analyticsStorageConsentGranted: analyticsStorage,
    adStorageConsentGranted: adStorage,
    adUserDataConsentGranted: adStorage,
    adPersonalizationSignalsConsentGranted: adStorage,
  );

  Future<void> setUserContext({
    String? uid,
    String? authMethod,
    int? clearedCount,
  }) async {
    await _analytics.setUserId(id: uid);
    if (authMethod != null) {
      await _analytics.setUserProperty(
        name: 'auth_method',
        value: authMethod,
      );
    }
    if (clearedCount != null) {
      await _analytics.setUserProperty(
        name: 'cleared_stage_count',
        value: clearedCount.toString(),
      );
    }
  }

  Future<void> initPlatformProperty() {
    final String platform;
    if (kIsWeb) {
      platform = 'web';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platform = 'ios';
    } else {
      platform = 'android';
    }
    return _analytics.setUserProperty(name: 'platform_kind', value: platform);
  }

  Future<void> logStageStart({
    required int stageNo,
    required String source,
  }) => _analytics.logEvent(
    name: 'stage_start',
    parameters: {'stage_no': stageNo, 'source': source},
  );

  Future<void> logStageClear({
    required int stageNo,
    required int boardSize,
    required int durationMs,
    required bool usedHint,
    required int tapsCount,
  }) => _analytics.logEvent(
    name: 'stage_clear',
    parameters: {
      'stage_no': stageNo,
      'board_size': boardSize,
      'duration_ms': durationMs,
      'used_hint': usedHint ? 1 : 0,
      'taps_count': tapsCount,
    },
  );

  Future<void> logStageFail({
    required int stageNo,
    required int whiteStonesCount,
  }) => _analytics.logEvent(
    name: 'stage_fail',
    parameters: {
      'stage_no': stageNo,
      'white_stones_count': whiteStonesCount,
    },
  );

  Future<void> logStageReset({required int stageNo}) => _analytics.logEvent(
    name: 'stage_reset',
    parameters: {'stage_no': stageNo},
  );

  Future<void> logHintRequested({
    required int stageNo,
    required bool adReady,
  }) => _analytics.logEvent(
    name: 'hint_requested',
    parameters: {'stage_no': stageNo, 'ad_ready': adReady ? 1 : 0},
  );

  Future<void> logHintAdShown({required int stageNo}) => _analytics.logEvent(
    name: 'hint_ad_shown',
    parameters: {'stage_no': stageNo},
  );

  Future<void> logHintRewardEarned({required int stageNo}) =>
      _analytics.logEvent(
        name: 'hint_reward_earned',
        parameters: {'stage_no': stageNo},
      );

  Future<void> logHintAdFailed({
    required int stageNo,
    required String reason,
  }) => _analytics.logEvent(
    name: 'hint_ad_failed',
    parameters: {'stage_no': stageNo, 'reason': reason},
  );

  Future<void> logLogin({required String method}) =>
      _analytics.logLogin(loginMethod: method);

  Future<void> logLogout() => _analytics.logEvent(name: 'logout');

  Future<void> logAccountDelete() =>
      _analytics.logEvent(name: 'account_delete');

  Future<void> logSyncStages({
    required String result,
    int? syncedCount,
    String? errorType,
  }) {
    final params = <String, Object>{'result': result};
    if (syncedCount != null) {
      params['synced_count'] = syncedCount;
    }
    if (errorType != null) {
      params['error_type'] = errorType;
    }
    return _analytics.logEvent(name: 'sync_stages', parameters: params);
  }

  Future<void> logDeepLinkOpen({
    required int stageNo,
    required String source,
  }) => _analytics.logEvent(
    name: 'deep_link_open',
    parameters: {'stage_no': stageNo, 'source': source},
  );

  Future<void> logNotificationOpen({required int stageNo}) =>
      _analytics.logEvent(
        name: 'notification_open',
        parameters: {'stage_no': stageNo},
      );
}

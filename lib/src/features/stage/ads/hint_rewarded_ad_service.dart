import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kyouen_flutter/src/data/ads/ad_config.dart';
import 'package:kyouen_flutter/src/data/analytics/analytics_service.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';

class HintRewardedAdNotifier extends Notifier<bool> {
  RewardedAd? _ad;
  bool _isLoading = false;
  Completer<void>? _loadCompleter;

  @override
  bool build() {
    ref.onDispose(() => _ad?.dispose());
    unawaited(_preload());
    return false;
  }

  Future<void> _preload() async {
    final adUnitId = AdConfig.rewardedAdUnitId;
    if (adUnitId.isEmpty || _isLoading) {
      return;
    }
    _isLoading = true;
    _loadCompleter = Completer<void>();
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (!ref.mounted) {
            ad.dispose();
            _isLoading = false;
            _loadCompleter?.complete();
            _loadCompleter = null;
            return;
          }
          _ad = ad;
          _isLoading = false;
          _loadCompleter?.complete();
          _loadCompleter = null;
          state = true;
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _loadCompleter?.complete();
          _loadCompleter = null;
        },
      ),
    );
  }

  Future<void> show({
    required VoidCallback onEarnedReward,
    required VoidCallback onFailed,
  }) async {
    final stageNo = ref.read(currentStageNoProvider).asData?.value ?? 0;
    final analytics = ref.read(analyticsServiceProvider);

    if (_ad == null) {
      // ロード中なら完了まで最大10秒待つ
      if (_isLoading) {
        try {
          await _loadCompleter?.future.timeout(const Duration(seconds: 10));
        } on TimeoutException {
          // タイムアウト: そのまま下の失敗処理へ
        }
      }
      if (_ad == null) {
        onFailed();
        unawaited(_preload());
        unawaited(
          analytics.logHintAdFailed(stageNo: stageNo, reason: 'no_fill'),
        );
        return;
      }
    }

    final ad = _ad!;
    _ad = null;
    if (ref.mounted) {
      state = false;
    }

    unawaited(analytics.logHintAdShown(stageNo: stageNo));

    final completer = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(_preload());
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onFailed();
        unawaited(_preload());
        unawaited(
          analytics.logHintAdFailed(stageNo: stageNo, reason: 'show_failed'),
        );
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );
    unawaited(
      ad.show(
        onUserEarnedReward: (ad, reward) {
          unawaited(analytics.logHintRewardEarned(stageNo: stageNo));
          onEarnedReward();
        },
      ),
    );

    await completer.future;
  }
}

final hintRewardedAdProvider = NotifierProvider<HintRewardedAdNotifier, bool>(
  HintRewardedAdNotifier.new,
);

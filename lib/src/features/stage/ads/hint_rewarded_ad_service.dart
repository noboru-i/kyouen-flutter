import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kyouen_flutter/src/data/ads/ad_config.dart';

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
          _ad = ad;
          _isLoading = false;
          _loadCompleter?.complete();
          _loadCompleter = null;
          if (ref.mounted) {
            state = true;
          }
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
        return;
      }
    }

    final ad = _ad!;
    _ad = null;
    if (ref.mounted) {
      state = false;
    }

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
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );
    unawaited(ad.show(onUserEarnedReward: (ad, reward) => onEarnedReward()));

    await completer.future;
  }
}

final hintRewardedAdProvider = NotifierProvider<HintRewardedAdNotifier, bool>(
  HintRewardedAdNotifier.new,
);

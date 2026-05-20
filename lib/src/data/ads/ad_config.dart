import 'package:flutter/foundation.dart';

class AdConfig {
  AdConfig._();

  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';

  static String get bannerAdUnitId {
    if (kIsWeb) {
      return '';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const String.fromEnvironment(
        'ADMOB_BANNER_ID_ANDROID',
        defaultValue: _testBannerAndroid,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const String.fromEnvironment(
        'ADMOB_BANNER_ID_IOS',
        defaultValue: _testBannerIOS,
      );
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) {
      return '';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const String.fromEnvironment(
        'ADMOB_REWARDED_ID_ANDROID',
        defaultValue: _testRewardedAndroid,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const String.fromEnvironment(
        'ADMOB_REWARDED_ID_IOS',
        defaultValue: _testRewardedIOS,
      );
    }
    return '';
  }
}

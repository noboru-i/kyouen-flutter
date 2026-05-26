import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kyouen_flutter/src/config/environment.dart';
import 'package:kyouen_flutter/src/data/analytics/analytics_service.dart';

final consentServiceProvider = Provider<ConsentService>(
  (ref) => ConsentService._(ref.read(analyticsServiceProvider)),
);

class ConsentService {
  ConsentService._(this._analytics);

  final AnalyticsService _analytics;

  ConsentRequestParameters _buildParams() {
    if (Environment.isDevelopment) {
      return ConsentRequestParameters(
        consentDebugSettings: ConsentDebugSettings(
          debugGeography: DebugGeography.debugGeographyEea,
        ),
      );
    }
    return ConsentRequestParameters();
  }

  /// UMP同意フローを実行する。
  /// 同意取得後にAnalyticsのConsent状態を更新する。
  Future<void> requestConsent() async {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      _buildParams(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((_) async {
          await _applyConsentToAnalytics();
          completer.complete();
        });
      },
      completer.completeError,
    );

    try {
      await completer.future;
    } on Object catch (_) {
      // 同意取得失敗時はデフォルト(denied)のまま続行
    }
  }

  /// 同意設定をリセットして再取得を促す。
  Future<void> resetConsent() async {
    await ConsentInformation.instance.reset();
    await requestConsent();
  }

  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  Future<void> _applyConsentToAnalytics() async {
    final canAds = await canRequestAds();
    await _analytics.setConsent(analyticsStorage: canAds, adStorage: canAds);
  }

  /// Options画面から「同意設定を変更」する際に使用するプライバシーオプションフォームを表示する。
  /// EEA以外の地域では何も起きない (UMP SDK が制御)。
  Future<void> showPrivacyOptions() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    if (status == PrivacyOptionsRequirementStatus.required) {
      final completer = Completer<void>();
      await ConsentForm.showPrivacyOptionsForm((_) {
        completer.complete();
      });
      await completer.future;
      await _applyConsentToAnalytics();
    }
  }

  Future<bool> get isPrivacyOptionsRequired async {
    if (kIsWeb) {
      return false;
    }
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }
}

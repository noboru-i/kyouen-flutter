import 'package:app_links/app_links.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:kyouen_flutter/firebase_options.dart';
import 'package:kyouen_flutter/src/app.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';

/// バックグラウンド・終了状態でのFCMメッセージハンドラー
/// トップレベル関数である必要がある
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await _setupFirebase();

  final initialStageNo = await _resolveInitialStageNo();

  runApp(
    ProviderScope(
      overrides: [
        if (initialStageNo != null)
          initialDeepLinkStageNoProvider.overrideWithValue(initialStageNo),
      ],
      child: const MyApp(),
    ),
  );
}

/// アプリ起動時のURLからステージ番号を解決する。
/// Web: パスベースURL (/stage?stage=N) のクエリパラメーターを直接読む。
/// ネイティブ: app_links でコールドスタートのURIを取得する。
Future<int?> _resolveInitialStageNo() async {
  Uri? uri;
  if (kIsWeb) {
    uri = Uri.base;
  } else {
    final appLinks = AppLinks();
    uri = await appLinks.getInitialLink();
  }
  return _extractStageNo(uri);
}

int? _extractStageNo(Uri? uri) {
  if (uri == null) {
    return null;
  }
  // `open` は旧URLフォーマット (?page_no=375&open=3756) 用
  final stageParam =
      uri.queryParameters['open'] ?? uri.queryParameters['stage'];
  if (stageParam == null) {
    return null;
  }
  final stageNo = int.tryParse(stageParam);
  if (stageNo == null || stageNo <= 0) {
    return null;
  }
  return stageNo;
}

Future<void> _setupFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kIsWeb) {
    await _setDefaultConsentDenied();
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    _setupMessaging();
  }
}

Future<void> _setDefaultConsentDenied() =>
    FirebaseAnalytics.instance.setConsent(
      analyticsStorageConsentGranted: false,
      adStorageConsentGranted: false,
      adUserDataConsentGranted: false,
      adPersonalizationSignalsConsentGranted: false,
    );

void _setupMessaging() {
  // バックグラウンドハンドラーの登録はアプリ起動直後に必要
  // 通知許可ダイアログは app.dart の _initTracking() で ATT・UMP の後に表示する
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

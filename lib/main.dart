import 'package:app_links/app_links.dart';
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
  final stageParam = uri.queryParameters['stage'];
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
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await _setupMessaging();
}

Future<void> _setupMessaging() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    await messaging.subscribeToTopic('stage_added');
  }
}

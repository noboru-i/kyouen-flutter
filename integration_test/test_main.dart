import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:kyouen_flutter/firebase_options.dart';
import 'package:kyouen_flutter/src/app.dart';

// スクリーンショット撮影用エントリポイント。
// - Firebase Messaging を省略: 通知許可ダイアログがテストをブロックするため
// - FlutterError.onError を上書きしない: テストフレームワークのエラーハンドラーを守るため
Future<void> mainForScreenshot() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

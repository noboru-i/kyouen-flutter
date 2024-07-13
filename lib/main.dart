import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/firebase_options.dart';
import 'package:kyouen_flutter/src/app.dart';
import 'package:kyouen_flutter/src/settings/settings_controller.dart';
import 'package:kyouen_flutter/src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _setupFirebase();

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  runApp(
    ProviderScope(
      child: MyApp(
        settingsController: settingsController,
      ),
    ),
  );
}

Future<void> _setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

// This is an example Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
//
// Visit https://flutter.dev/docs/cookbook/testing/widget/introduction for
// more information about Widget testing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyouen_flutter/src/app.dart';
import 'package:kyouen_flutter/src/settings/settings_controller.dart';
import 'package:kyouen_flutter/src/settings/settings_service.dart';

void main() {
  group('MyApp', () {
    testWidgets('should render title page initially', (WidgetTester tester) async {
      final settingsController = SettingsController(SettingsService());
      await settingsController.loadSettings();

      // Build the app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(settingsController: settingsController),
        ),
      );

      // Verify the app shows the title page with expected buttons
      expect(find.text('スタート'), findsOneWidget);
      expect(find.text('ログイン'), findsOneWidget);
    });
  });
}

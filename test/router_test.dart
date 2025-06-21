import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyouen_flutter/src/config/router.dart';
import 'package:kyouen_flutter/src/settings/settings_controller.dart';
import 'package:kyouen_flutter/src/settings/settings_service.dart';

void main() {
  group('Router Configuration', () {
    late SettingsController settingsController;

    setUp(() {
      settingsController = SettingsController(SettingsService());
    });

    testWidgets('should have correct initial route', (WidgetTester tester) async {
      final router = createRouter(settingsController);
      
      // Verify initial location is set to root
      expect(router.routerDelegate.currentConfiguration.uri.toString(), '/');
    });

    testWidgets('should navigate to stage page', (WidgetTester tester) async {
      final router = createRouter(settingsController);
      
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      
      // Verify we're on the title page initially
      expect(find.text('スタート'), findsOneWidget);
      expect(find.text('ログイン'), findsOneWidget);
      
      // Tap the start button to navigate to stage
      await tester.tap(find.text('スタート'));
      await tester.pumpAndSettle();
      
      // Verify we navigated to stage page
      expect(router.routerDelegate.currentConfiguration.uri.toString(), '/stage');
    });

    testWidgets('should navigate to sign in page', (WidgetTester tester) async {
      final router = createRouter(settingsController);
      
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      
      // Tap the login button to navigate to sign in
      await tester.tap(find.text('ログイン'));
      await tester.pumpAndSettle();
      
      // Verify we navigated to sign in page
      expect(router.routerDelegate.currentConfiguration.uri.toString(), '/sign_in');
    });
  });
}
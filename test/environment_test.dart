import 'package:flutter_test/flutter_test.dart';
import 'package:kyouen_flutter/src/config/environment.dart';

void main() {
  group('Environment Configuration Tests', () {
    test('should use default production values when no dart-define is set', () {
      // These tests assume no dart-define values are set, so defaults should be used
      expect(Environment.environmentType, equals('prod'));
      expect(Environment.isProduction, isTrue);
      expect(Environment.isDevelopment, isFalse);
      expect(Environment.apiBaseUrl, equals('https://kyouen.app/v2/'));
      expect(Environment.firebaseProjectId, equals('api-project-732262258565'));
      expect(Environment.appName, equals('詰め共円'));
    });

    test('should return correct app name for production environment', () {
      // In production, app name should not have DEV prefix
      expect(Environment.appName, equals('詰め共円'));
    });
  });
}
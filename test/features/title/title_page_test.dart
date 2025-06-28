import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyouen_flutter/src/features/title/title_page.dart';
import 'package:kyouen_flutter/src/data/local/cleared_stages_service.dart';

// Mock for testing
class MockClearedStagesService extends ClearedStagesService {
  MockClearedStagesService() : super(null!);
  
  @override
  Future<Map<String, int>> getStageCount() async {
    // Return mock data for testing
    return {
      'count': 10,
      'clear_count': 3,
    };
  }
}

void main() {
  group('TitlePage Stage Count Display', () {
    testWidgets('should display stage count correctly', (WidgetTester tester) async {
      // Create override for the service provider
      final container = ProviderContainer(
        overrides: [
          clearedStagesServiceProvider.overrideWithValue(MockClearedStagesService()),
        ],
      );

      // Build the title page with provider scope
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TitlePage(),
          ),
        ),
      );

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Verify that stage count is displayed
      expect(find.text('クリアステージ数: 3 / 10'), findsOneWidget);
      
      // Verify that the main UI elements are present
      expect(find.text('スタート'), findsOneWidget);
      expect(find.text('ログイン'), findsOneWidget);
    });

    testWidgets('should show loading state initially', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          clearedStagesServiceProvider.overrideWithValue(MockClearedStagesService()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TitlePage(),
          ),
        ),
      );

      // Before pumpAndSettle, should show loading state
      expect(find.text('ステージ情報を読み込み中...'), findsOneWidget);
    });
  });
}
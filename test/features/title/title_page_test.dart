import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/features/title/native_title_page.dart';

// Mock for testing
class MockStageRepository implements StageRepository {
  @override
  Future<Map<String, int>> getStageCount() async {
    // Return mock data for testing
    return {'count': 10, 'clear_count': 3};
  }

  @override
  Future<void> markStageCleared(int stageNo) async {
    // Mock implementation - do nothing
  }

  @override
  Future<Set<int>> getClearedStageNumbers() async {
    // Mock implementation - return empty set
    return <int>{};
  }

  @override
  Future<bool> isStageCleared(int stageNo) async {
    // Mock implementation - return false
    return false;
  }

  // Add other required methods as no-op implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('TitlePage Stage Count Display', () {
    testWidgets('should display stage count correctly', (
      WidgetTester tester,
    ) async {
      // Create override for the repository provider
      final container = ProviderContainer(
        overrides: [
          stageRepositoryProvider.overrideWith(
            (ref) => Future.value(MockStageRepository()),
          ),
        ],
      );

      // Build the title page with provider scope
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TitlePage()),
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

    testWidgets('should show loading state initially', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          stageRepositoryProvider.overrideWith(
            (ref) => Future.value(MockStageRepository()),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TitlePage()),
        ),
      );

      // Before pumpAndSettle, should show loading state
      expect(find.text('ステージ情報を読み込み中...'), findsOneWidget);
    });
  });
}

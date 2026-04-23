import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/features/title/native_title_page.dart';
import 'package:kyouen_flutter/src/features/title/total_stage_count_provider.dart';

// totalStageCountProvider のモック（常に 10 を返す）
class MockTotalStageCount extends TotalStageCount {
  @override
  Future<int> build() async => 10;
}

// Mock for testing
class MockStageRepository implements StageRepository {
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
    return false;
  }

  @override
  Future<int> getClearedCount() async {
    return 3;
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
          totalStageCountProvider.overrideWith(MockTotalStageCount.new),
        ],
      );

      // Build the title page with provider scope
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TitlePage()),
        ),
      );

      // Advance past the 500ms Future.delayed timer in _KyouenDiagramState
      await tester.pump(const Duration(milliseconds: 600));
      // Wait for async operations (FutureBuilder) to complete
      await tester.pumpAndSettle();

      // Verify that stage count is displayed
      expect(find.text('3 / 10 ステージクリア'), findsOneWidget);

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
          totalStageCountProvider.overrideWith(MockTotalStageCount.new),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TitlePage()),
        ),
      );

      // Before async operations complete, should show loading state
      expect(find.text('読み込み中...'), findsOneWidget);

      // Clean up: advance past the 500ms Future.delayed timer in _KyouenDiagramState
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
    });
  });
}

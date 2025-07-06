import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyouen_flutter/src/data/api/entity/stage_response.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/features/stage/stage_page.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';

void main() {
  group('StagePage Navigation Tests', () {
    testWidgets('Previous button should be disabled when currentStageNo is 1', (WidgetTester tester) async {
      // Create a test app with providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock the current stage number to be 1
            currentStageNoProvider.overrideWith((ref) => 1),
            // Mock the current stage data
            currentStageProvider.overrideWith((ref) => 
              AsyncData(StageResponse(
                stageNo: 1,
                size: 3,
                stage: '111111111',
                creator: 'test',
                registDate: '',
              ))
            ),
            // Mock cleared stages
            clearedStageNumbersProvider.overrideWith((ref) => AsyncData(<int>{})),
          ],
          child: const MaterialApp(
            home: StagePage(),
          ),
        ),
      );

      // Let the widget build
      await tester.pumpAndSettle();

      // Find the previous button by its text
      final previousButton = find.widgetWithText(FilledButton, '前へ');
      expect(previousButton, findsOneWidget);

      // Check that the button is disabled (onPressed should be null)
      final FilledButton button = tester.widget<FilledButton>(previousButton);
      expect(button.onPressed, isNull, reason: 'Previous button should be disabled when on stage 1');
    });

    testWidgets('Previous button should be enabled when currentStageNo is greater than 1', (WidgetTester tester) async {
      // Create a test app with providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock the current stage number to be 2
            currentStageNoProvider.overrideWith((ref) => 2),
            // Mock the current stage data
            currentStageProvider.overrideWith((ref) => 
              AsyncData(StageResponse(
                stageNo: 2,
                size: 3,
                stage: '111111111',
                creator: 'test',
                registDate: '',
              ))
            ),
            // Mock cleared stages
            clearedStageNumbersProvider.overrideWith((ref) => AsyncData(<int>{})),
          ],
          child: const MaterialApp(
            home: StagePage(),
          ),
        ),
      );

      // Let the widget build
      await tester.pumpAndSettle();

      // Find the previous button by its text
      final previousButton = find.widgetWithText(FilledButton, '前へ');
      expect(previousButton, findsOneWidget);

      // Check that the button is enabled (onPressed should not be null)
      final FilledButton button = tester.widget<FilledButton>(previousButton);
      expect(button.onPressed, isNotNull, reason: 'Previous button should be enabled when on stage > 1');
    });

    testWidgets('Next button should always be enabled', (WidgetTester tester) async {
      // Create a test app with providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock the current stage number to be 1
            currentStageNoProvider.overrideWith((ref) => 1),
            // Mock the current stage data
            currentStageProvider.overrideWith((ref) => 
              AsyncData(StageResponse(
                stageNo: 1,
                size: 3,
                stage: '111111111',
                creator: 'test',
                registDate: '',
              ))
            ),
            // Mock cleared stages
            clearedStageNumbersProvider.overrideWith((ref) => AsyncData(<int>{})),
          ],
          child: const MaterialApp(
            home: StagePage(),
          ),
        ),
      );

      // Let the widget build
      await tester.pumpAndSettle();

      // Find the next button by its text
      final nextButton = find.widgetWithText(FilledButton, '次へ');
      expect(nextButton, findsOneWidget);

      // Check that the button is enabled (onPressed should not be null)
      final FilledButton button = tester.widget<FilledButton>(nextButton);
      expect(button.onPressed, isNotNull, reason: 'Next button should always be enabled');
    });
  });
}
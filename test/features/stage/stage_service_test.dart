import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/local/preference_service.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CurrentStageNo with Persistence', () {
    late ProviderContainer container;

    setUp(() async {
      // Set up SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('currentStageNo should start with default value 1', () {
      final stageNo = container.read(currentStageNoProvider);
      expect(stageNo, 1);
    });

    test('currentStageNo should save and load from preferences', () async {
      final notifier = container.read(currentStageNoProvider.notifier);
      
      // Change to a different stage
      notifier.setStageNo(42);
      expect(container.read(currentStageNoProvider), 42);
      
      // Wait for save to complete
      await Future.delayed(Duration(milliseconds: 100));
      
      // Verify it was saved to preferences
      final prefService = await container.read(preferenceServiceProvider.future);
      expect(prefService.getLastStageNo(), 42);
    });

    test('next() should increment stage number and save it', () async {
      final notifier = container.read(currentStageNoProvider.notifier);
      
      // Start with stage 1
      expect(container.read(currentStageNoProvider), 1);
      
      // Go to next stage
      notifier.next();
      expect(container.read(currentStageNoProvider), 2);
      
      // Wait for save to complete
      await Future.delayed(Duration(milliseconds: 100));
      
      // Verify it was saved to preferences
      final prefService = await container.read(preferenceServiceProvider.future);
      expect(prefService.getLastStageNo(), 2);
    });

    test('prev() should decrement stage number and save it', () async {
      final notifier = container.read(currentStageNoProvider.notifier);
      
      // Start with stage 5
      notifier.setStageNo(5);
      expect(container.read(currentStageNoProvider), 5);
      
      // Go to previous stage
      notifier.prev();
      expect(container.read(currentStageNoProvider), 4);
      
      // Wait for save to complete
      await Future.delayed(Duration(milliseconds: 100));
      
      // Verify it was saved to preferences
      final prefService = await container.read(preferenceServiceProvider.future);
      expect(prefService.getLastStageNo(), 4);
    });

    test('prev() should not go below 1', () async {
      final notifier = container.read(currentStageNoProvider.notifier);
      
      // Start with stage 1
      expect(container.read(currentStageNoProvider), 1);
      
      // Try to go to previous stage (should stay at 1)
      notifier.prev();
      expect(container.read(currentStageNoProvider), 1);
      
      // Wait for save to complete
      await Future.delayed(Duration(milliseconds: 100));
      
      // Verify it's still 1 in preferences
      final prefService = await container.read(preferenceServiceProvider.future);
      expect(prefService.getLastStageNo(), 1);
    });

    test('setStageNo() should not set stage number below 1', () async {
      final notifier = container.read(currentStageNoProvider.notifier);
      
      // Try to set stage number to 0 (should be ignored)
      notifier.setStageNo(0);
      expect(container.read(currentStageNoProvider), 1);
      
      // Try to set stage number to -1 (should be ignored)
      notifier.setStageNo(-1);
      expect(container.read(currentStageNoProvider), 1);
    });

    test('initialStageNoProvider should return saved stage number', () async {
      // Save a stage number to preferences
      final prefService = await container.read(preferenceServiceProvider.future);
      await prefService.setLastStageNo(25);
      
      // Create a new container to simulate app restart
      final newContainer = ProviderContainer();
      
      // Check that initialStageNoProvider returns the saved value
      final initialStageNo = await newContainer.read(initialStageNoProvider.future);
      expect(initialStageNo, 25);
      
      newContainer.dispose();
    });

    test('initialStageNoProvider should return 1 when no value is saved', () async {
      // Create a new container with clean preferences
      final newContainer = ProviderContainer();
      
      // Check that initialStageNoProvider returns default value
      final initialStageNo = await newContainer.read(initialStageNoProvider.future);
      expect(initialStageNo, 1);
      
      newContainer.dispose();
    });
  });
}
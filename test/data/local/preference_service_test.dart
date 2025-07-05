import 'package:flutter_test/flutter_test.dart';
import 'package:kyouen_flutter/src/data/local/preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferenceService', () {
    late PreferenceService preferenceService;

    setUp(() async {
      // Set up SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      preferenceService = PreferenceService(prefs);
    });

    test('getLastStageNo should return 1 when no value is saved', () {
      expect(preferenceService.getLastStageNo(), 1);
    });

    test('setLastStageNo should save and retrieve stage number', () async {
      const testStageNo = 42;
      
      await preferenceService.setLastStageNo(testStageNo);
      expect(preferenceService.getLastStageNo(), testStageNo);
    });

    test('setLastStageNo should overwrite previous value', () async {
      const firstStageNo = 10;
      const secondStageNo = 20;
      
      await preferenceService.setLastStageNo(firstStageNo);
      expect(preferenceService.getLastStageNo(), firstStageNo);
      
      await preferenceService.setLastStageNo(secondStageNo);
      expect(preferenceService.getLastStageNo(), secondStageNo);
    });

    test('getLastStageNo should return correct value after app restart simulation', () async {
      const testStageNo = 99;
      await preferenceService.setLastStageNo(testStageNo);
      
      // Simulate app restart by creating a new instance
      final prefs = await SharedPreferences.getInstance();
      final newPreferenceService = PreferenceService(prefs);
      
      expect(newPreferenceService.getLastStageNo(), testStageNo);
    });

    test('setLastStageNo should handle multiple values correctly', () async {
      final testCases = [1, 5, 10, 25, 50, 100];
      
      for (final stageNo in testCases) {
        await preferenceService.setLastStageNo(stageNo);
        expect(preferenceService.getLastStageNo(), stageNo);
      }
    });

    test('setLastStageNo should persist across multiple operations', () async {
      const stageNo = 42;
      
      await preferenceService.setLastStageNo(stageNo);
      
      // Perform multiple reads
      for (int i = 0; i < 10; i++) {
        expect(preferenceService.getLastStageNo(), stageNo);
      }
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:kyouen_flutter/src/data/database/database_service.dart';
import 'package:kyouen_flutter/src/data/database/stage_entity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseService databaseService;

  setUpAll(() {
    // Initialize FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    databaseService = DatabaseService();
  });

  tearDown(() async {
    await databaseService.close();
  });

  group('DatabaseService', () {
    test('should create database and table', () async {
      final db = await databaseService.database;
      expect(db, isA<Database>());
      
      // Verify table exists by trying to query it
      final result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='tume_kyouen';");
      expect(result.length, 1);
    });

    test('should insert and retrieve stage', () async {
      const stage = StageEntity(
        stageNo: 1,
        size: 9,
        stage: '000000000',
        creator: 'Test Creator',
        clearFlag: 0,
        clearDate: 0,
      );

      final id = await databaseService.insertStage(stage);
      expect(id, greaterThan(0));

      final retrievedStage = await databaseService.getStage(1);
      expect(retrievedStage, isNotNull);
      expect(retrievedStage!.stageNo, 1);
      expect(retrievedStage.creator, 'Test Creator');
      expect(retrievedStage.isCleared, false);
    });

    test('should update clear status', () async {
      const stage = StageEntity(
        stageNo: 2,
        size: 9,
        stage: '000000000',
        creator: 'Test Creator',
      );

      await databaseService.insertStage(stage);
      
      // Mark as cleared
      await databaseService.updateClearStatus(2, true);
      
      final updatedStage = await databaseService.getStage(2);
      expect(updatedStage!.isCleared, true);
      expect(updatedStage.clearDate, greaterThan(0));
    });

    test('should get stages with filters', () async {
      // Insert multiple stages
      for (int i = 10; i <= 15; i++) {
        final stage = StageEntity(
          stageNo: i,
          size: 9,
          stage: '000000000',
          creator: 'Creator $i',
        );
        await databaseService.insertStage(stage);
      }

      final stages = await databaseService.getStages(startStageNo: 12, limit: 3);
      expect(stages.length, 3);
      expect(stages.first.stageNo, 12);
      expect(stages.last.stageNo, 14);
    });

    test('should handle stage not found', () async {
      final stage = await databaseService.getStage(999);
      expect(stage, isNull);
    });
  });
}
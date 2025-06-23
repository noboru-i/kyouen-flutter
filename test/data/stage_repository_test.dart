import 'package:flutter_test/flutter_test.dart';
import 'package:kyouen_flutter/src/data/local/entity/tume_kyouen.dart';

void main() {
  group('TumeKyouen Entity Tests', () {
    test('should create TumeKyouen with required fields', () {
      const tumeKyouen = TumeKyouen(
        stageNo: 1,
        size: 3,
        stage: '111\n111\n111',
        creator: 'test_user',
        clearFlag: TumeKyouen.notCleared,
        clearDate: 0,
      );

      expect(tumeKyouen.stageNo, 1);
      expect(tumeKyouen.size, 3);
      expect(tumeKyouen.stage, '111\n111\n111');
      expect(tumeKyouen.creator, 'test_user');
      expect(tumeKyouen.clearFlag, TumeKyouen.notCleared);
      expect(tumeKyouen.clearDate, 0);
      expect(tumeKyouen.uid, isNull);
    });

    test('should create TumeKyouen with uid', () {
      const tumeKyouen = TumeKyouen(
        uid: 123,
        stageNo: 1,
        size: 3,
        stage: '111\n111\n111',
        creator: 'test_user',
        clearFlag: TumeKyouen.cleared,
        clearDate: 1234567890,
      );

      expect(tumeKyouen.uid, 123);
      expect(tumeKyouen.clearFlag, TumeKyouen.cleared);
      expect(tumeKyouen.clearDate, 1234567890);
    });

    test('should convert to/from JSON correctly', () {
      const originalTumeKyouen = TumeKyouen(
        uid: 456,
        stageNo: 2,
        size: 4,
        stage: '1111\n1111\n1111\n1111',
        creator: 'json_test_user',
        clearFlag: TumeKyouen.cleared,
        clearDate: 9876543210,
      );

      final json = originalTumeKyouen.toJson();
      final reconstructedTumeKyouen = TumeKyouen.fromJson(json);

      expect(reconstructedTumeKyouen, equals(originalTumeKyouen));
    });

    test('should use correct constants', () {
      expect(TumeKyouen.tableName, 'tume_kyouen');
      expect(TumeKyouen.cleared, 1);
      expect(TumeKyouen.notCleared, 0);
    });
  });
}

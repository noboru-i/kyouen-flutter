import 'package:flutter_test/flutter_test.dart';
import 'package:kyouen_flutter/src/features/notification/push_notification_service.dart';

void main() {
  group('extractTargetStageNo', () {
    test('returns max value from valid stage_nos array', () {
      expect(extractTargetStageNo({'stage_nos': '[1,2,3]'}), 3);
    });

    test('returns null for empty array', () {
      expect(extractTargetStageNo({'stage_nos': '[]'}), isNull);
    });

    test('returns null when stage_nos key is absent', () {
      expect(extractTargetStageNo({}), isNull);
    });

    test('returns null for invalid JSON string', () {
      expect(extractTargetStageNo({'stage_nos': 'invalid'}), isNull);
    });

    test('handles string-encoded numbers and returns int max', () {
      expect(extractTargetStageNo({'stage_nos': '["10", 11]'}), 11);
    });

    test('returns null when all values are zero or negative', () {
      expect(extractTargetStageNo({'stage_nos': '[0, -1]'}), isNull);
    });

    test('returns single valid value', () {
      expect(extractTargetStageNo({'stage_nos': '[42]'}), 42);
    });

    test('returns null for non-string stage_nos', () {
      expect(extractTargetStageNo({'stage_nos': 123}), isNull);
    });

    test('returns null for empty string', () {
      expect(extractTargetStageNo({'stage_nos': ''}), isNull);
    });

    test('ignores non-numeric entries and returns max of valid ones', () {
      expect(extractTargetStageNo({'stage_nos': '[5, "abc", 3]'}), 5);
    });
  });
}

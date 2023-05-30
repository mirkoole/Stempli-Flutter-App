import 'package:stempli_flutter/utils/datetime.dart';
import 'package:test/test.dart';

void main() {
  group('date time ', () {
    test('getAdjustIntervalMinute', () {
      expect(getAdjustIntervalMinute(0), "");
      expect(getAdjustIntervalMinute(60), "1 Min");
      expect(getAdjustIntervalMinute(600), "10 Min");
      expect(getAdjustIntervalMinute(3600), "60 Min");
    });

    test('convertDurationToSeconds', () {
      expect(convertDurationToSeconds(const Duration(minutes: 1)), 60);
      expect(convertDurationToSeconds(const Duration(hours: 1)), 60 * 60);
      expect(convertDurationToSeconds(const Duration(hours: 2)), 2 * 60 * 60);
      expect(convertDurationToSeconds(const Duration(hours: 1, minutes: 30)),
          90 * 60);
      expect(convertDurationToSeconds(const Duration(hours: 8, minutes: 0)),
          8 * 60 * 60);
    });

    test('getDailyWorkTimeString', () {
      expect(getDailyWorkTimeString(8 * 60 * 60), '8:00 h');
      expect(getDailyWorkTimeString(7 * 60 * 60), '7:00 h');
      expect(getDailyWorkTimeString(6 * 60 * 60), '6:00 h');

      expect(getDailyWorkTimeString(60 * 36 + 7 * 60 * 60), '7:36 h');
      expect(getDailyWorkTimeString(60 * 30 + 7 * 60 * 60), '7:30 h');
      expect(getDailyWorkTimeString(60 * 15), '0:15 h');
    });
  });
}

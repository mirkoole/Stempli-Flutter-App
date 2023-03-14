import 'package:stempli_flutter/utils/datetime.dart';
import 'package:test/test.dart';

void main() {
  group('date time ', () {
    test('calcWeeklyWorkTimeToDailyWorktime', () {
      expect(calcWeeklyWorkTimeToDailyWorktime(40, 5), 8.0);
      expect(calcWeeklyWorkTimeToDailyWorktime(30, 5), 6.0);
      expect(calcWeeklyWorkTimeToDailyWorktime(38, 5), 7.6);

      expect(calcWeeklyWorkTimeToDailyWorktime(32, 4), 8.0);
    });

    test('getDailyWorkTimeString', () {
      expect(getDailyWorkTimeString(8.0), "8:00 h");
      expect(getDailyWorkTimeString(7.0), "7:00 h");
      expect(getDailyWorkTimeString(6.0), "6:00 h");

      expect(getDailyWorkTimeString(7.6), "7:36 h");
      expect(getDailyWorkTimeString(7.5), "7:30 h");
    });
  });
}
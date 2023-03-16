double calcWeeklyWorkTimeToDailyWorktime(
    double weeklyWorkHours, int weeklyWorkDays) {
  if (weeklyWorkDays < 1) return -1;
  if (weeklyWorkDays > 7) return -1;
  if (weeklyWorkHours < 0) return -1;

  if (weeklyWorkHours == 0) return 0;

  double dailyWorkTime = weeklyWorkHours / weeklyWorkDays;

  return dailyWorkTime;
}

String getDailyWorkTimeString(double dailyWorkTime) {
  if (dailyWorkTime < 0) return "";
  if (dailyWorkTime > 24) return "";
  if (dailyWorkTime == 0.0) return "0:00 h";
  if (dailyWorkTime == 24.0) return "24:00 h";

  int dailyWorkHour = dailyWorkTime.truncate();
  double dailyWorkMinute = dailyWorkTime - dailyWorkHour; // 6.5 - 6 = 0.5 Hour
  int dailyWorkMinute2 = (dailyWorkMinute * 60).round(); // 0.5 * 60 = 30 Minutes

  return "$dailyWorkHour:${twoDigits(dailyWorkMinute2)} h";
}

String twoDigits(int n) => n.toString().padLeft(2, "0");

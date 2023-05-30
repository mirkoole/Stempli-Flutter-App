// ignore_for_file: public_member_api_docs

// remember store in seconds, calc in seconds, reformat to display HH:mm

String getDayOfWeek() {
  switch (DateTime.now().weekday) {
    case 1:
      return "mon";
    case 2:
      return "tue";
    case 3:
      return "wed";
    case 4:
      return "thu";
    case 5:
      return "fri";
    case 6:
      return "sat";
    case 7:
      return "sun";
    default:
      return "";
  }
}

int convertDurationToSeconds(Duration duration) {
  final time = duration.toString().split(":");
  final hour = int.parse(time[0]);
  final minute = int.parse(time[1]);
  return (hour * 60 + minute) * 60;
}

String getDailyWorkTimeString(int dailyWorkTimeInSeconds) {
  if (dailyWorkTimeInSeconds < 0) return '';
  if (dailyWorkTimeInSeconds > 24 * 60 * 60 * 60) return '';
  if (dailyWorkTimeInSeconds == 0) return '';
  if (dailyWorkTimeInSeconds == 24 * 60 * 60 * 60) return '24:00 h';

  final duration = Duration(seconds: dailyWorkTimeInSeconds);

  final time = duration.toString().split(":");
  final hour = int.parse(time[0]);
  final minute = int.parse(time[1]);

  return '$hour:${twoDigits(minute)} h';
}

String getAdjustIntervalMinute(int inputDuration) {
  if (inputDuration <= 0) return '';

  inputDuration = inputDuration ~/ 60;

  return '$inputDuration Min';
}

String twoDigits(int n) => n.toString().padLeft(2, '0');

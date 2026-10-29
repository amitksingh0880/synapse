import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class DateTimeUtil {
  DateTimeUtil._();

  /// Calculates the current DaySector based on local hour
  static DaySector getCurrentDaySector([DateTime? customTime]) {
    final now = customTime ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return DaySector.morning;
    } else if (hour >= 12 && hour < 18) {
      return DaySector.afternoon;
    } else if (hour >= 18 && hour < 24) {
      return DaySector.evening;
    } else {
      return DaySector.night;
    }
  }

  /// Formats time in clean 12-hour or 24-hour style e.g. "08:30 AM"
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  /// Human-readable date e.g. "Wednesday, Oct 28"
  static String formatHeaderDate([DateTime? date]) {
    return DateFormat('EEEE, MMM d').format(date ?? DateTime.now());
  }

  /// Checks if two DateTimes fall on the exact same calendar day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Human-friendly relative timestamp
  static String relativeTimeSpan(DateTime past) {
    final diff = DateTime.now().difference(past);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(past);
  }
}

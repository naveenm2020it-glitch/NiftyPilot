import 'package:intl/intl.dart';

class DateUtilsExt {
  DateUtilsExt._();

  static String toDateKey(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime fromDateKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return DateTime.now();
    return DateTime(
      int.tryParse(parts[0]) ?? DateTime.now().year,
      int.tryParse(parts[1]) ?? DateTime.now().month,
      int.tryParse(parts[2]) ?? DateTime.now().day,
    );
  }

  static DateTime stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime startOfWeek(DateTime dt) {
    final clean = stripTime(dt);
    // Monday as start of week
    final diff = clean.weekday - DateTime.monday;
    return clean.subtract(Duration(days: diff));
  }

  static String formatReadableDate(DateTime dt, {String locale = 'en'}) {
    try {
      return DateFormat('EEEE, MMM d', locale).format(dt);
    } catch (_) {
      return DateFormat('EEEE, MMM d').format(dt);
    }
  }

  static String formatShortDate(DateTime dt) {
    return DateFormat('MMM d, yyyy').format(dt);
  }

  static String formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  static String formatMinutesAsDuration(int totalMinutes) {
    final hrs = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hrs == 0) return '${mins}m';
    if (mins == 0) return '${hrs}h';
    return '${hrs}h ${mins}m';
  }
}

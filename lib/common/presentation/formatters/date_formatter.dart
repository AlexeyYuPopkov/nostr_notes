import 'package:intl/intl.dart';

final class DateFormatter {
  static final time = DateFormat('HH:mm');
  static final dateTime = DateFormat('d MMM, y');

  static String formatDateTimeOrEmpty(DateTime? date) {
    if (date == null) {
      return '';
    }

    return date.isToday() ? time.format(date) : dateTime.format(date);
  }
}

extension on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

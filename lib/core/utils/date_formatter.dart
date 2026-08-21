import 'package:intl/intl.dart';

class DateFormatter {
  // Format for chat list: "17 june, 2025  3:50 pm"
  static String formatChatListDate(DateTime dateTime) {
    final day = DateFormat('d').format(dateTime);
    final month = DateFormat('MMMM').format(dateTime).toLowerCase();
    final year = DateFormat('yyyy').format(dateTime);
    final time = DateFormat('h:mm a').format(dateTime).toLowerCase();
    return '$day $month, $year  $time';
  }

  // Format for message bubbles: "14/06/2025  |  16:10 Pm"
  static String formatMessageTimestamp(DateTime dateTime) {
    final date = DateFormat('dd/MM/yyyy').format(dateTime);
    final timeHour = DateFormat('HH:mm').format(dateTime);
    final amPm = DateFormat('a').format(dateTime);
    // Capitalize first letter of am/pm like "Pm" as in screenshot
    final formattedAmPm = amPm.isNotEmpty 
        ? '${amPm[0].toUpperCase()}${amPm.substring(1).toLowerCase()}'
        : '';
    return '$date  |  $timeHour $formattedAmPm';
  }
}

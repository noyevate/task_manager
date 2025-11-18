import 'package:intl/intl.dart';

String formatDateTime(DateTime dateTime, {bool includeTime = false}) {
  final date = DateFormat('MMM d, yyyy').format(dateTime);
  if (includeTime) {
    final time = DateFormat('h:mm a').format(dateTime);
    return '$date at $time';
  }
  return date;
}
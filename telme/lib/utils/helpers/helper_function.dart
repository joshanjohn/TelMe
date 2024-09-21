import 'package:intl/intl.dart';

class AppHelper {
  static String extractShiftStamp(
      {required DateTime dateTime, required String format}) {
    return DateFormat(format).format(dateTime);
  }
}

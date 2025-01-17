import 'package:intl/intl.dart';

String getDay() {
    DateTime now = DateTime.now();
    return DateFormat('EEEE').format(now);
  }

  String getFormattedDatePart() {
    DateTime now = DateTime.now();
    return DateFormat('MMM d, y').format(now);
  }
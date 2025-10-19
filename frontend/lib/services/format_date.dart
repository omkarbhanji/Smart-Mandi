import 'package:intl/intl.dart';

String formatDate(String isoDate) {
  DateTime date = DateTime.parse(isoDate);
  return DateFormat('dd/MM/yyyy').format(date);
}

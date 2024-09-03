import 'package:intl/intl.dart';
import 'dart:math';

class Utils {
  static String formatDateTime(DateTime dateTime) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    String formattedTime = '${dateTime.hour}h:${dateTime.minute.toString().padLeft(2, '0')}min';
    return '$formattedDate $formattedTime';
  }

  static double roundToDecimal(double number, int decimalPlaces) {
    double mod = pow(10.0, decimalPlaces.toDouble()) as double;
    return ((number * mod).round().toDouble() / mod);
  }

  // New method to format numbers with commas
  static String formatNumberWithCommas(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  // Method to round to nearest integer (without commas)
  static double formatToInteger(double number) {
    return number.roundToDouble(); // Rounds to nearest integer
  }

  static String getCurrentMonth() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMM');
    return formatter.format(now);
  }
}

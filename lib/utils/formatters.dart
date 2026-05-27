import 'package:intl/intl.dart';

String formatIndianCurrency(double amount) {
  if (amount >= 10000000) {
    return '\u20B9${(amount / 10000000).toStringAsFixed(2)} Cr';
  } else if (amount >= 100000) {
    return '\u20B9${(amount / 100000).toStringAsFixed(2)} L';
  }
  final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9', decimalDigits: 0);
  return formatter.format(amount);
}

String formatCurrencyFull(double amount) {
  final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9', decimalDigits: 0);
  return formatter.format(amount);
}

String formatPercentage(double value) {
  return '${value.toStringAsFixed(1)}%';
}

String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

String formatDateShort(DateTime date) {
  return DateFormat('dd/MM/yy').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('dd MMM yyyy, h:mm a').format(date);
}

String formatCompactAmount(double amount) {
  if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(1)}Cr';
  if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
  if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
  return amount.toStringAsFixed(0);
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'formatters.dart' as fmt;

class Helpers {
  static String formatDate(DateTime date) => fmt.formatDate(date);
  static String formatDateShort(DateTime date) => fmt.formatDateShort(date);
  static String formatDateTime(DateTime date) => fmt.formatDateTime(date);
  static String formatCurrency(double amount) => fmt.formatIndianCurrency(amount);
  static String formatCurrencyFull(double amount) => fmt.formatCurrencyFull(amount);
  static String formatPercentage(double value) => fmt.formatPercentage(value);
  static String formatCompactAmount(double amount) => fmt.formatCompactAmount(amount);
}

void showAppSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.dangerRed : AppTheme.successGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

Future<bool> showAppConfirmDialog(BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.isEmpty) return 'Phone number is required';
  if (value.length != 10) return 'Enter a valid 10-digit phone number';
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Phone must contain only digits';
  return null;
}

String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) return '$fieldName is required';
  return null;
}

String? validateAmount(String? value) {
  if (value == null || value.isEmpty) return 'Amount is required';
  final amount = double.tryParse(value);
  if (amount == null || amount <= 0) return 'Enter a valid amount';
  return null;
}

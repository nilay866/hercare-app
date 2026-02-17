import 'package:flutter/material.dart';
import '../services/app_logger.dart';

class UiUtils {
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  static void showError(BuildContext context, dynamic error) {
    final message = error.toString().replaceAll('Exception: ', '');
    AppLogger.log('UiUtils.showError', message, error: error);
    showSnackBar(context, message, isError: true);
  }

  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message);
  }
}

import 'package:flutter/material.dart';
import 'package:famihub_flutter/core/theme/app_theme.dart';

class UIHelpers {
  static void showMessageBox(BuildContext context, String title, String message,
      {bool isError = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isError ? AppColors.rejected : AppColors.primary,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.rejected : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

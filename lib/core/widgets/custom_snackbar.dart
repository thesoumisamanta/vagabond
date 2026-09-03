import 'dart:ui';
import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(BuildContext context, {required String message, required Color backgroundColor, IconData? icon}) {
    final messenger = ScaffoldMessenger.of(context);
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: backgroundColor.withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              children: [
                if (icon != null) ...[Icon(icon, color: backgroundColor, size: 24), const SizedBox(width: 12)],
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => messenger.hideCurrentSnackBar(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.6), size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: const Color(0xFF10B981), // Emerald 500
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showWarning(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: const Color(0xFFF59E0B), // Amber 500
      icon: Icons.warning_amber_rounded,
    );
  }

  static void showError(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: const Color(0xFFEF4444), // Red 500
      icon: Icons.error_outline_rounded,
    );
  }
}

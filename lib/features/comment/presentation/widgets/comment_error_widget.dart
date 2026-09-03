import 'package:flutter/material.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class CommentErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const CommentErrorWidget({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: onRetry,
            child: const Text(AppStrings.homeRetry),
          ),
        ],
      ),
    );
  }
}

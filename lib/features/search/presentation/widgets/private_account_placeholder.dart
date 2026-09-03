import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class PrivateAccountPlaceholder extends StatelessWidget {
  const PrivateAccountPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            children: [
              Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.4), size: 48),
              const SizedBox(height: 12),
              const Text(
                AppStrings.searchPrivateAccountTitle,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.searchPrivateAccountSubtitle,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

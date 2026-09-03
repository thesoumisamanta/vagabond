import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final double iconSize;
  final double titleFontSize;

  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = const Color(0xFF6366F1),
    this.iconSize = 40.0,
    this.titleFontSize = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withOpacity(0.1)),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

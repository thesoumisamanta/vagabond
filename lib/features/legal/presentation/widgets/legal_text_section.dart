import 'package:flutter/material.dart';
import 'package:vagabond/features/legal/presentation/widgets/legal_glass_container.dart';

class LegalTextSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String text;

  const LegalTextSection({super.key, required this.title, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return LegalGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), height: 1.6)),
        ],
      ),
    );
  }
}

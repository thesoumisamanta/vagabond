import 'package:flutter/material.dart';
import 'package:vagabond/features/legal/presentation/widgets/legal_glass_container.dart';

class LegalListSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const LegalListSection({super.key, required this.title, required this.icon, required this.items});

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
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6.0, right: 12.0),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

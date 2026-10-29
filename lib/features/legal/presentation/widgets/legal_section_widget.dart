import 'package:flutter/material.dart';
import 'package:vagabond/features/legal/domain/entities/legal_section.dart';
import 'package:vagabond/features/legal/presentation/widgets/legal_glass_container.dart';

class LegalSectionWidget extends StatelessWidget {
  final LegalSection section;

  const LegalSectionWidget({super.key, required this.section});

  IconData _getSectionIcon() {
    final titleUpper = section.title.toUpperCase();
    final number = section.sectionNumber;

    if (number == 1 || titleUpper.contains('ELIGIBILITY') || titleUpper.contains('COLLECT')) {
      return Icons.assignment_outlined;
    } else if (number == 2 || titleUpper.contains('CONTENT') || titleUpper.contains('PERMISSIONS')) {
      return Icons.perm_device_information_outlined;
    } else if (number == 3 || titleUpper.contains('MODERATION') || titleUpper.contains('USE YOUR INFORMATION')) {
      return Icons.security_outlined;
    } else if (number == 4 || titleUpper.contains('PROHIBITED') || titleUpper.contains('THIRD-PARTY')) {
      return Icons.extension_outlined;
    } else if (number == 5 || titleUpper.contains('INTELLECTUAL') || titleUpper.contains('SECURITY')) {
      return Icons.lock_outlined;
    } else if (number == 6 || titleUpper.contains('DELETION') || titleUpper.contains('RETENTION')) {
      return Icons.delete_sweep_outlined;
    } else if (number == 7 || titleUpper.contains('DISCLAIMER') || titleUpper.contains('CHILDREN')) {
      return Icons.child_care_outlined;
    } else if (number == 8 || titleUpper.contains('GOVERNING') || titleUpper.contains('RIGHTS')) {
      return Icons.gavel_outlined;
    } else if (number == 9 || titleUpper.contains('CHANGES')) {
      return Icons.history_outlined;
    } else if (number == 10 || titleUpper.contains('CONTACT')) {
      return Icons.contact_support_outlined;
    }
    return Icons.description_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final sectionTitle = section.sectionNumber != null
        ? '${section.sectionNumber}. ${section.title}'
        : section.title;

    return LegalGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Icon(_getSectionIcon(), color: const Color(0xFF6366F1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sectionTitle,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          if (section.preamble != null && section.preamble!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              section.preamble!,
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), height: 1.5),
            ),
          ],
          if (section.subsections != null && section.subsections!.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...section.subsections!.map((sub) => Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF818CF8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...sub.items.map((item) => _buildListItem(item)),
                    ],
                  ),
                )),
          ],
          if (section.items != null && section.items!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...section.items!.map((item) => _buildListItem(item)),
          ],
          if (section.closing != null && section.closing!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              section.closing!,
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.7), height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7.0, right: 10.0),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}


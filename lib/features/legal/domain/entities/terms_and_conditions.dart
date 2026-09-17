import 'package:vagabond/features/legal/domain/entities/legal_section.dart';

class TermsAndConditions {
  final String title;
  final String effectiveDate;
  final String? lastUpdated;
  final String version;
  final String? introduction;
  final List<LegalSection> sections;

  const TermsAndConditions({
    required this.title,
    required this.effectiveDate,
    this.lastUpdated,
    required this.version,
    this.introduction,
    required this.sections,
  });
}

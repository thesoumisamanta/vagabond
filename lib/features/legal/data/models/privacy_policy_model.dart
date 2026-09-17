import 'package:vagabond/features/legal/data/models/legal_section_model.dart';
import 'package:vagabond/features/legal/domain/entities/privacy_policy.dart';

class PrivacyPolicyModel extends PrivacyPolicy {
  const PrivacyPolicyModel({
    required super.title,
    required super.effectiveDate,
    super.lastUpdated,
    required super.version,
    super.introduction,
    required super.sections,
  });

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    final contentJson = json['content'] as Map<String, dynamic>?;
    final sectionsJson = json['sections'] as List<dynamic>? ?? [];

    return PrivacyPolicyModel(
      title: json['title'] ?? '',
      effectiveDate: json['effectiveDate'] ?? '',
      lastUpdated: json['lastUpdated'] as String?,
      version: json['version'] ?? '',
      introduction: contentJson?['introduction'] as String?,
      sections: sectionsJson
          .map((s) => LegalSectionModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'effectiveDate': effectiveDate,
      'lastUpdated': lastUpdated,
      'version': version,
      'content': {
        if (introduction != null) 'introduction': introduction,
      },
      'sections': sections
          .map((s) => (s as LegalSectionModel).toJson())
          .toList(),
    };
  }
}

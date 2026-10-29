import 'package:vagabond/features/legal/domain/entities/legal_section.dart';

class LegalSubsectionModel extends LegalSubsection {
  const LegalSubsectionModel({
    required super.subtitle,
    required super.items,
  });

  factory LegalSubsectionModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>?;
    return LegalSubsectionModel(
      subtitle: json['subtitle'] ?? '',
      items: itemsJson?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtitle': subtitle,
      'items': items,
    };
  }
}

class LegalSectionModel extends LegalSection {
  const LegalSectionModel({
    super.sectionNumber,
    required super.title,
    super.preamble,
    super.subsections,
    super.items,
    super.closing,
  });

  factory LegalSectionModel.fromJson(Map<String, dynamic> json) {
    final subsectionsJson = json['subsections'] as List<dynamic>?;
    final itemsJson = json['items'] as List<dynamic>?;

    return LegalSectionModel(
      sectionNumber: json['sectionNumber'] as int?,
      title: json['title'] ?? '',
      preamble: json['preamble'] as String?,
      subsections: subsectionsJson
          ?.map((sub) => LegalSubsectionModel.fromJson(sub as Map<String, dynamic>))
          .toList(),
      items: itemsJson?.map((e) => e.toString()).toList(),
      closing: json['closing'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionNumber': sectionNumber,
      'title': title,
      'preamble': preamble,
      'subsections': subsections
          ?.map((sub) => (sub as LegalSubsectionModel).toJson())
          .toList(),
      'items': items,
      'closing': closing,
    };
  }
}


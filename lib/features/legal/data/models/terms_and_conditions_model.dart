import 'package:vagabond/features/legal/domain/entities/terms_and_conditions.dart';

class TermsAndConditionsModel extends TermsAndConditions {
  const TermsAndConditionsModel({
    required super.title,
    required super.effectiveDate,
    required super.version,
    required super.content,
  });

  factory TermsAndConditionsModel.fromJson(Map<String, dynamic> json) {
    return TermsAndConditionsModel(
      title: json['title'] ?? '',
      effectiveDate: json['effectiveDate'] ?? '',
      version: json['version'] ?? '',
      content: TermsAndConditionsContentModel.fromJson(json['content'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'effectiveDate': effectiveDate,
      'version': version,
      'content': (content as TermsAndConditionsContentModel).toJson(),
    };
  }
}

class TermsAndConditionsContentModel extends TermsAndConditionsContent {
  const TermsAndConditionsContentModel({
    required super.introduction,
    required super.userAccounts,
    required super.contentGuidelines,
    required super.termination,
    required super.governingLaw,
  });

  factory TermsAndConditionsContentModel.fromJson(Map<String, dynamic> json) {
    return TermsAndConditionsContentModel(
      introduction: json['introduction'] ?? '',
      userAccounts: List<String>.from(json['userAccounts'] ?? []),
      contentGuidelines: List<String>.from(json['contentGuidelines'] ?? []),
      termination: json['termination'] ?? '',
      governingLaw: json['governingLaw'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'introduction': introduction,
      'userAccounts': userAccounts,
      'contentGuidelines': contentGuidelines,
      'termination': termination,
      'governingLaw': governingLaw,
    };
  }
}

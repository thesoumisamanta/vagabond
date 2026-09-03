import 'package:vagabond/features/legal/domain/entities/privacy_policy.dart';

class PrivacyPolicyModel extends PrivacyPolicy {
  const PrivacyPolicyModel({
    required super.title,
    required super.effectiveDate,
    required super.version,
    required super.content,
  });

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(
      title: json['title'] ?? '',
      effectiveDate: json['effectiveDate'] ?? '',
      version: json['version'] ?? '',
      content: PrivacyPolicyContentModel.fromJson(json['content'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'effectiveDate': effectiveDate,
      'version': version,
      'content': (content as PrivacyPolicyContentModel).toJson(),
    };
  }
}

class PrivacyPolicyContentModel extends PrivacyPolicyContent {
  const PrivacyPolicyContentModel({
    required super.informationCollected,
    required super.howWeUseInformation,
    required super.thirdPartyServices,
    required super.dataRights,
  });

  factory PrivacyPolicyContentModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyContentModel(
      informationCollected: List<String>.from(json['informationCollected'] ?? []),
      howWeUseInformation: List<String>.from(json['howWeUseInformation'] ?? []),
      thirdPartyServices: List<String>.from(json['thirdPartyServices'] ?? []),
      dataRights: json['dataRights'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'informationCollected': informationCollected,
      'howWeUseInformation': howWeUseInformation,
      'thirdPartyServices': thirdPartyServices,
      'dataRights': dataRights,
    };
  }
}

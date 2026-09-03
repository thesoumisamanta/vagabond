class PrivacyPolicy {
  final String title;
  final String effectiveDate;
  final String version;
  final PrivacyPolicyContent content;

  const PrivacyPolicy({required this.title, required this.effectiveDate, required this.version, required this.content});
}

class PrivacyPolicyContent {
  final List<String> informationCollected;
  final List<String> howWeUseInformation;
  final List<String> thirdPartyServices;
  final String dataRights;

  const PrivacyPolicyContent({
    required this.informationCollected,
    required this.howWeUseInformation,
    required this.thirdPartyServices,
    required this.dataRights,
  });
}

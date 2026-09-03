class TermsAndConditions {
  final String title;
  final String effectiveDate;
  final String version;
  final TermsAndConditionsContent content;

  const TermsAndConditions({
    required this.title,
    required this.effectiveDate,
    required this.version,
    required this.content,
  });
}

class TermsAndConditionsContent {
  final String introduction;
  final List<String> userAccounts;
  final List<String> contentGuidelines;
  final String termination;
  final String governingLaw;

  const TermsAndConditionsContent({
    required this.introduction,
    required this.userAccounts,
    required this.contentGuidelines,
    required this.termination,
    required this.governingLaw,
  });
}

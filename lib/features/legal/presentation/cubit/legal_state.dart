import 'package:vagabond/features/legal/domain/entities/privacy_policy.dart';
import 'package:vagabond/features/legal/domain/entities/terms_and_conditions.dart';

abstract class LegalState {
  const LegalState();
}

class LegalInitial extends LegalState {}

class LegalLoading extends LegalState {}

class PrivacyPolicyLoaded extends LegalState {
  final PrivacyPolicy privacyPolicy;

  const PrivacyPolicyLoaded(this.privacyPolicy);
}

class TermsAndConditionsLoaded extends LegalState {
  final TermsAndConditions termsAndConditions;

  const TermsAndConditionsLoaded(this.termsAndConditions);
}

class LegalError extends LegalState {
  final String message;

  const LegalError(this.message);
}

import 'package:vagabond/features/legal/domain/entities/privacy_policy.dart';
import 'package:vagabond/features/legal/domain/entities/terms_and_conditions.dart';

abstract class LegalRepository {
  Future<PrivacyPolicy> getPrivacyPolicy();
  Future<TermsAndConditions> getTermsAndConditions();
}

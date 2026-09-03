import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/core/network/api_endpoints.dart';
import 'package:vagabond/features/legal/data/models/privacy_policy_model.dart';
import 'package:vagabond/features/legal/data/models/terms_and_conditions_model.dart';

abstract class LegalRemoteDataSource {
  Future<PrivacyPolicyModel> getPrivacyPolicy();
  Future<TermsAndConditionsModel> getTermsAndConditions();
}

class LegalRemoteDataSourceImpl implements LegalRemoteDataSource {
  final ApiClient apiClient;

  LegalRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PrivacyPolicyModel> getPrivacyPolicy() async {
    final response = await apiClient.get(ApiEndpoints.privacyPolicy);
    final data = response.data as Map<String, dynamic>;
    final privacyData = data['data'] as Map<String, dynamic>;
    return PrivacyPolicyModel.fromJson(privacyData);
  }

  @override
  Future<TermsAndConditionsModel> getTermsAndConditions() async {
    final response = await apiClient.get(ApiEndpoints.termsAndConditions);
    final data = response.data as Map<String, dynamic>;
    final termsData = data['data'] as Map<String, dynamic>;
    return TermsAndConditionsModel.fromJson(termsData);
  }
}

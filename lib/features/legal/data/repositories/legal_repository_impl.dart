import 'package:vagabond/features/legal/domain/entities/privacy_policy.dart';
import 'package:vagabond/features/legal/domain/entities/terms_and_conditions.dart';
import 'package:vagabond/features/legal/domain/repositories/legal_repository.dart';
import 'package:vagabond/features/legal/data/datasources/legal_remote_datasource.dart';

class LegalRepositoryImpl implements LegalRepository {
  final LegalRemoteDataSource remoteDataSource;

  LegalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PrivacyPolicy> getPrivacyPolicy() async {
    try {
      return await remoteDataSource.getPrivacyPolicy();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TermsAndConditions> getTermsAndConditions() async {
    try {
      return await remoteDataSource.getTermsAndConditions();
    } catch (e) {
      rethrow;
    }
  }
}

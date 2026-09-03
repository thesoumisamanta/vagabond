import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/features/legal/domain/repositories/legal_repository.dart';
import 'package:vagabond/features/legal/presentation/cubit/legal_state.dart';

class LegalCubit extends Cubit<LegalState> {
  final LegalRepository legalRepository;

  LegalCubit({required this.legalRepository}) : super(LegalInitial());

  Future<void> getPrivacyPolicy() async {
    emit(LegalLoading());
    try {
      final privacyPolicy = await legalRepository.getPrivacyPolicy();
      emit(PrivacyPolicyLoaded(privacyPolicy));
    } catch (e) {
      emit(LegalError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> getTermsAndConditions() async {
    emit(LegalLoading());
    try {
      final termsAndConditions = await legalRepository.getTermsAndConditions();
      emit(TermsAndConditionsLoaded(termsAndConditions));
    } catch (e) {
      emit(LegalError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

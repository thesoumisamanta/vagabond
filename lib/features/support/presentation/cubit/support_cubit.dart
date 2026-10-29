import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/support/domain/repositories/support_repository.dart';
import 'package:vagabond/features/support/presentation/cubit/support_state.dart';

class SupportCubit extends Cubit<SupportState> {
  final SupportRepository supportRepository;

  SupportCubit({required this.supportRepository}) : super(SupportInitial());

  Future<void> submitContactSupport({
    required String name,
    required String email,
    required String subject,
    required String message,
    String priority = 'medium',
  }) async {
    emit(SupportLoading());
    try {
      final ticket = await supportRepository.contactSupport(
        name: name,
        email: email,
        subject: subject,
        message: message,
        priority: priority,
      );
      emit(SupportContactSuccess(
        ticket: ticket,
        message: AppStrings.helpSupportSuccessMessage,
      ));
    } catch (e) {
      emit(SupportFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> fetchMyTickets() async {
    emit(SupportLoading());
    try {
      final tickets = await supportRepository.getMyTickets();
      emit(SupportTicketsLoaded(tickets: tickets));
    } catch (e) {
      emit(SupportFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}


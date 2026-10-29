import 'package:vagabond/features/support/domain/entities/support_ticket.dart';

abstract class SupportState {
  const SupportState();
}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportContactSuccess extends SupportState {
  final SupportTicket ticket;
  final String message;

  const SupportContactSuccess({required this.ticket, required this.message});
}

class SupportFailure extends SupportState {
  final String error;

  const SupportFailure({required this.error});
}

class SupportTicketsLoaded extends SupportState {
  final List<SupportTicket> tickets;

  const SupportTicketsLoaded({required this.tickets});
}


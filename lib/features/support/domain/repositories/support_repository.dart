import 'package:vagabond/features/support/domain/entities/support_ticket.dart';

abstract class SupportRepository {
  Future<SupportTicket> contactSupport({
    required String name,
    required String email,
    required String subject,
    required String message,
    String priority = 'medium',
  });

  Future<List<SupportTicket>> getMyTickets();
}


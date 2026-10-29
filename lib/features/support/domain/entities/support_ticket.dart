class SupportTicket {
  final String ticketId;
  final String name;
  final String email;
  final String subject;
  final String message;
  final String priority;
  final String status;
  final DateTime? createdAt;

  const SupportTicket({
    required this.ticketId,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    this.priority = 'medium',
    this.status = 'open',
    this.createdAt,
  });
}


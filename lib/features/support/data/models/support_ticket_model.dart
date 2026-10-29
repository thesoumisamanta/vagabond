import 'package:vagabond/features/support/domain/entities/support_ticket.dart';

class SupportTicketModel extends SupportTicket {
  const SupportTicketModel({
    required super.ticketId,
    required super.name,
    required super.email,
    required super.subject,
    required super.message,
    super.priority,
    super.status,
    super.createdAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      ticketId: json['ticketId'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'open',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'priority': priority,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}


import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/core/network/api_endpoints.dart';
import 'package:vagabond/features/support/data/models/support_ticket_model.dart';

abstract class SupportRemoteDataSource {
  Future<SupportTicketModel> contactSupport({
    required String name,
    required String email,
    required String subject,
    required String message,
    String priority = 'medium',
  });

  Future<List<SupportTicketModel>> getMyTickets();
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final ApiClient apiClient;

  SupportRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SupportTicketModel> contactSupport({
    required String name,
    required String email,
    required String subject,
    required String message,
    String priority = 'medium',
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.supportContact,
      data: {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'priority': priority,
      },
    );
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    return SupportTicketModel.fromJson(data);
  }

  @override
  Future<List<SupportTicketModel>> getMyTickets() async {
    final response = await apiClient.get(ApiEndpoints.supportTickets);
    final responseData = response.data as Map<String, dynamic>;
    final list = responseData['data'] as List<dynamic>? ?? [];
    return list
        .map((item) => SupportTicketModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}


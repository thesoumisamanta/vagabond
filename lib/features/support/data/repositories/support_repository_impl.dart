import 'package:vagabond/features/support/data/datasources/support_remote_datasource.dart';
import 'package:vagabond/features/support/domain/entities/support_ticket.dart';
import 'package:vagabond/features/support/domain/repositories/support_repository.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource remoteDataSource;

  SupportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SupportTicket> contactSupport({
    required String name,
    required String email,
    required String subject,
    required String message,
    String priority = 'medium',
  }) async {
    try {
      return await remoteDataSource.contactSupport(
        name: name,
        email: email,
        subject: subject,
        message: message,
        priority: priority,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SupportTicket>> getMyTickets() async {
    try {
      return await remoteDataSource.getMyTickets();
    } catch (e) {
      rethrow;
    }
  }
}


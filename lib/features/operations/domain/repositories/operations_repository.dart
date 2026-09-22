import 'package:another_home/core/network/dtos/operations_models.dart';

abstract class OperationsRepository {
  Future<List<IncidentModel>> getIncidents();

  Future<IncidentModel> reportIncident({
    required IncidentCategory category,
    required String title,
    required String description,
    required String roomId,
  });

  Future<List<VisitorRequestModel>> getVisitors();

  Future<VisitorRequestModel> requestVisitor({
    required String roomId,
    required String visitorName,
    required String visitorContact,
    required String purpose,
    required String visitDate,
    required String visitTime,
  });

  Future<List<NoticeModel>> getNotices();
}

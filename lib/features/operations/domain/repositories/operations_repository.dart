import 'package:another_home/core/network/dtos/operations_models.dart';

abstract class OperationsRepository {
  Future<List<IncidentModel>> getIncidents();
  
  Future<IncidentModel> reportIncident({
    required IncidentCategory category,
    required String description,
    required String roomId,
  });

  Future<List<VisitorRequestModel>> getVisitors();

  Future<VisitorRequestModel> requestVisitor({
    required String studentId,
    required String visitorName,
    required String relation,
    required String expectedDate,
  });
}

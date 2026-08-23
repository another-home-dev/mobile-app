import 'package:another_home/core/network/dtos/operations_models.dart';

abstract class ComplaintEvent {
  const ComplaintEvent();
}

class LoadComplaints extends ComplaintEvent {
  const LoadComplaints();
}

class SubmitComplaint extends ComplaintEvent {
  final IncidentCategory category;
  final String description;
  final String roomId;

  const SubmitComplaint({
    required this.category,
    required this.description,
    required this.roomId,
  });
}

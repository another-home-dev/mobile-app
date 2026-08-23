abstract class VisitorEvent {
  const VisitorEvent();
}

class LoadVisitors extends VisitorEvent {
  const LoadVisitors();
}

class SubmitVisitorRequest extends VisitorEvent {
  final String studentId;
  final String visitorName;
  final String relation;
  final String expectedDate;

  const SubmitVisitorRequest({
    required this.studentId,
    required this.visitorName,
    required this.relation,
    required this.expectedDate,
  });
}

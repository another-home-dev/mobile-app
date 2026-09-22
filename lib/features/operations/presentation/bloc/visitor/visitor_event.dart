abstract class VisitorEvent {
  const VisitorEvent();
}

class LoadVisitors extends VisitorEvent {
  const LoadVisitors();
}

class SubmitVisitorRequest extends VisitorEvent {
  final String roomId;
  final String visitorName;
  final String visitorContact;
  final String purpose;
  final String visitDate;
  final String visitTime;

  const SubmitVisitorRequest({
    required this.roomId,
    required this.visitorName,
    required this.visitorContact,
    required this.purpose,
    required this.visitDate,
    required this.visitTime,
  });
}

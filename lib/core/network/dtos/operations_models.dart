enum IncidentCategory {
  plumbing,
  electrical,
  furniture,
  other,
}

class ReportIncidentDto {
  final IncidentCategory category;
  final String title;
  final String description;
  final String roomId;
  final String priority; // 'Low' | 'Medium' | 'High' — matches the backend's MaintenancePriority

  const ReportIncidentDto({
    required this.category,
    required this.title,
    required this.description,
    required this.roomId,
    this.priority = 'Medium',
  });

  Map<String, dynamic> toJson() => {
        'category': category == IncidentCategory.plumbing
            ? 'Plumbing'
            : category == IncidentCategory.electrical
                ? 'Electrical'
                : category == IncidentCategory.furniture
                    ? 'Furniture'
                    : 'Other',
        'title': title,
        'description': description,
        'roomId': roomId,
        'priority': priority,
      };
}

/// Matches the backend's CreateVisitorRequestDto exactly (operations service, /operations/visitors).
class RequestVisitorDto {
  final String roomId;
  final String visitorName;
  final String visitorContact;
  final String purpose;
  final String visitDate; // format: YYYY-MM-DD
  final String visitTime;

  const RequestVisitorDto({
    required this.roomId,
    required this.visitorName,
    required this.visitorContact,
    required this.purpose,
    required this.visitDate,
    required this.visitTime,
  });

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'visitorName': visitorName,
        'visitorContact': visitorContact,
        'purpose': purpose,
        'visitDate': visitDate,
        'visitTime': visitTime,
      };
}

class CreateNoticeDto {
  final String title;
  final String content;

  const CreateNoticeDto({
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
      };
}

/// Maps the backend's MaintenanceRequest entity (id, studentId, roomId, category,
/// title, description, priority, status, assignedStaff, submittedDate) served at
/// GET/POST /operations/maintenance.
class IncidentModel {
  final String incidentId;
  final String category;
  final String title;
  final String description;
  final String roomId;
  final String status;
  final String reportedBy;
  final String? assignedStaff;
  final DateTime createdAt;

  const IncidentModel({
    required this.incidentId,
    required this.category,
    required this.title,
    required this.description,
    required this.roomId,
    required this.status,
    required this.reportedBy,
    this.assignedStaff,
    required this.createdAt,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) => IncidentModel(
        incidentId: json['id'] as String,
        category: json['category'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String,
        roomId: json['roomId'] as String,
        status: json['status'] as String,
        reportedBy: json['studentId'] as String? ?? '',
        assignedStaff: json['assignedStaff'] as String?,
        createdAt: DateTime.parse(json['submittedDate'] as String),
      );
}

/// Maps the backend's VisitorRequest entity (id, studentId, roomId, visitorName,
/// visitorContact, purpose, visitDate, visitTime, status) served at
/// GET/POST /operations/visitors. There's no NIC or free-text "relation" field on
/// the backend — `relation` here just carries `purpose` through for existing UI code.
class VisitorRequestModel {
  final String visitorId;
  final String studentId;
  final String roomId;
  final String visitorName;
  final String visitorContact;
  final String relation;
  final String expectedDate;
  final String visitTime;
  final String status;

  const VisitorRequestModel({
    required this.visitorId,
    required this.studentId,
    required this.roomId,
    required this.visitorName,
    required this.visitorContact,
    required this.relation,
    required this.expectedDate,
    required this.visitTime,
    required this.status,
  });

  factory VisitorRequestModel.fromJson(Map<String, dynamic> json) =>
      VisitorRequestModel(
        visitorId: json['id'] as String,
        studentId: json['studentId'] as String,
        roomId: json['roomId'] as String? ?? '',
        visitorName: json['visitorName'] as String,
        visitorContact: json['visitorContact'] as String? ?? '',
        relation: json['purpose'] as String? ?? '',
        expectedDate: json['visitDate'] as String,
        visitTime: json['visitTime'] as String? ?? '',
        status: json['status'] as String,
      );
}

/// Maps the backend's Notice entity (id, authorId, title, content, publishedDate)
/// served at GET/POST /operations/notices.
class NoticeModel {
  final String id;
  final String title;
  final String content;
  final String publishedBy;
  final DateTime publishedAt;

  const NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedBy,
    required this.publishedAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) => NoticeModel(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        publishedBy: json['authorId'] as String? ?? 'Warden',
        publishedAt: DateTime.parse(json['publishedDate'] as String),
      );
}

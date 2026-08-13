enum IncidentCategory {
  plumbing,
  electrical,
  furniture,
  other,
}

class ReportIncidentDto {
  final IncidentCategory category;
  final String description;
  final String roomId;

  const ReportIncidentDto({
    required this.category,
    required this.description,
    required this.roomId,
  });

  Map<String, dynamic> toJson() => {
        'category': category == IncidentCategory.plumbing
            ? 'Plumbing'
            : category == IncidentCategory.electrical
                ? 'Electrical'
                : category == IncidentCategory.furniture
                    ? 'Furniture'
                    : 'Other',
        'description': description,
        'roomId': roomId,
      };
}

class RequestVisitorDto {
  final String studentId;
  final String visitorName;
  final String relation;
  final String expectedDate; // format: YYYY-MM-DD

  const RequestVisitorDto({
    required this.studentId,
    required this.visitorName,
    required this.relation,
    required this.expectedDate,
  });

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'visitorName': visitorName,
        'relation': relation,
        'expectedDate': expectedDate,
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

class IncidentModel {
  final String incidentId;
  final String category;
  final String description;
  final String roomId;
  final String status;
  final String reportedBy;
  final DateTime? resolvedAt;
  final DateTime createdAt;

  const IncidentModel({
    required this.incidentId,
    required this.category,
    required this.description,
    required this.roomId,
    required this.status,
    required this.reportedBy,
    this.resolvedAt,
    required this.createdAt,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) => IncidentModel(
        incidentId: json['incidentId'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
        roomId: json['roomId'] as String,
        status: json['status'] as String,
        reportedBy: json['reportedBy'] as String,
        resolvedAt: json['resolvedAt'] != null
            ? DateTime.parse(json['resolvedAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class VisitorRequestModel {
  final String visitorId;
  final String studentId;
  final String visitorName;
  final String relation;
  final String expectedDate;
  final String status;
  final String? remarks;
  final DateTime createdAt;

  const VisitorRequestModel({
    required this.visitorId,
    required this.studentId,
    required this.visitorName,
    required this.relation,
    required this.expectedDate,
    required this.status,
    this.remarks,
    required this.createdAt,
  });

  factory VisitorRequestModel.fromJson(Map<String, dynamic> json) =>
      VisitorRequestModel(
        visitorId: json['visitorId'] as String,
        studentId: json['studentId'] as String,
        visitorName: json['visitorName'] as String,
        relation: json['relation'] as String,
        expectedDate: json['expectedDate'] as String,
        status: json['status'] as String,
        remarks: json['remarks'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

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
        publishedBy: json['publishedBy'] as String,
        publishedAt: DateTime.parse(json['publishedAt'] as String),
      );
}

enum ApprovalStatus {
  approved,
  rejected,
}

class RegisterStudentDto {
  final String studentId;
  final String fullName;
  final String email;
  final String password;
  final String contactNumber;

  const RegisterStudentDto({
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.password,
    required this.contactNumber,
  });

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'fullName': fullName,
        'email': email,
        'password': password,
        'contactNumber': contactNumber,
      };
}

class ApprovalDto {
  final ApprovalStatus status;
  final String? remarks;

  const ApprovalDto({required this.status, this.remarks});

  Map<String, dynamic> toJson() => {
        'status': status == ApprovalStatus.approved ? 'APPROVED' : 'REJECTED',
        if (remarks != null) 'remarks': remarks,
      };
}

class PendingRegistrationModel {
  final String id;
  final String studentId;
  final String fullName;
  final String email;
  final String contactNumber;
  final String status;
  final DateTime createdAt;

  const PendingRegistrationModel({
    required this.id,
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.contactNumber,
    required this.status,
    required this.createdAt,
  });

  factory PendingRegistrationModel.fromJson(Map<String, dynamic> json) =>
      PendingRegistrationModel(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        contactNumber: json['contactNumber'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class AuthResponseModel {
  final String token;
  final String userId;
  final String email;
  final String name;
  final String? role;

  const AuthResponseModel({
    required this.token,
    required this.userId,
    required this.email,
    required this.name,
    this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        token: json['token'] as String,
        userId: json['userId'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        role: json['role'] as String?,
      );
}

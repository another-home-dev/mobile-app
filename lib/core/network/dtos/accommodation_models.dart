enum RoomDesignation {
  male,
  female,
  neutral,
}

String _designationToGender(RoomDesignation designation) {
  switch (designation) {
    case RoomDesignation.male:
      return 'Male';
    case RoomDesignation.female:
      return 'Female';
    case RoomDesignation.neutral:
      return 'Neutral';
  }
}

class CreateRoomDto {
  final String roomNumber;
  final int capacity;
  final RoomDesignation designation;
  final String airConditioning;
  final double rentPerMonth;
  final int floor;
  final String? buildingId;

  const CreateRoomDto({
    required this.roomNumber,
    required this.capacity,
    required this.designation,
    required this.airConditioning,
    required this.rentPerMonth,
    required this.floor,
    this.buildingId,
  });

  Map<String, dynamic> toJson() => {
        'roomNumber': roomNumber,
        'capacity': capacity,
        'gender': _designationToGender(designation),
        'airConditioning': airConditioning,
        'rentPerMonth': rentPerMonth,
        'floor': floor,
        if (buildingId != null) 'buildingId': buildingId,
      };
}

class AllocateBedDto {
  final String studentId;
  final String bedId;

  const AllocateBedDto({
    required this.studentId,
    required this.bedId,
  });

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'bedId': bedId,
      };
}

class AssignedStudentModel {
  final String? id;
  final String name;

  const AssignedStudentModel({required this.id, required this.name});

  factory AssignedStudentModel.fromJson(Map<String, dynamic> json) =>
      AssignedStudentModel(
        id: json['id'] as String?,
        name: json['name'] as String? ?? 'Unknown',
      );
}

class RoomModel {
  final String roomId;
  final String roomNumber;
  final int capacity;
  final String gender;
  final bool isAvailable;
  final String airConditioning;
  final double rentPerMonth;
  final int floor;
  final String? buildingId;
  final int occupiedBeds;
  final List<AssignedStudentModel> assignedStudents;

  const RoomModel({
    required this.roomId,
    required this.roomNumber,
    required this.capacity,
    required this.gender,
    required this.isAvailable,
    required this.airConditioning,
    required this.rentPerMonth,
    required this.floor,
    this.buildingId,
    required this.occupiedBeds,
    required this.assignedStudents,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
        roomId: json['roomId'] as String,
        roomNumber: json['roomNumber'] as String,
        capacity: json['capacity'] as int,
        gender: json['gender'] as String,
        isAvailable: json['isAvailable'] as bool? ?? true,
        airConditioning: json['airConditioning'] as String,
        rentPerMonth: (json['rentPerMonth'] as num).toDouble(),
        floor: json['floor'] as int,
        buildingId: json['buildingId'] as String?,
        occupiedBeds: json['occupiedBeds'] as int? ?? 0,
        assignedStudents: (json['assignedStudents'] as List<dynamic>? ?? [])
            .map((s) => AssignedStudentModel.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

/// The current student's own record, resolved via GET /accommodation/students/me.
class StudentModel {
  final String id;
  final String studentCode;
  final String name;
  final String email;
  final String contact;
  final String? faculty;
  final String? degreeProgram;
  final String? academicYear;
  final String? nic;

  const StudentModel({
    required this.id,
    required this.studentCode,
    required this.name,
    required this.email,
    required this.contact,
    this.faculty,
    this.degreeProgram,
    this.academicYear,
    this.nic,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['id'] as String,
        studentCode: json['studentCode'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        contact: json['contact'] as String,
        faculty: json['faculty'] as String?,
        degreeProgram: json['degreeProgram'] as String?,
        academicYear: json['academicYear'] as String?,
        nic: json['nic'] as String?,
      );
}

class BedAllocationModel {
  final String bedId;
  final String roomId;
  final String? studentId;
  final bool isOccupied;
  final DateTime? allocatedAt;

  const BedAllocationModel({
    required this.bedId,
    required this.roomId,
    required this.studentId,
    required this.isOccupied,
    required this.allocatedAt,
  });

  factory BedAllocationModel.fromJson(Map<String, dynamic> json) =>
      BedAllocationModel(
        bedId: json['id'] as String,
        roomId: json['roomId'] as String,
        studentId: json['studentId'] as String?,
        isOccupied: json['isOccupied'] as bool? ?? false,
        allocatedAt: json['allocatedAt'] != null
            ? DateTime.parse(json['allocatedAt'] as String)
            : null,
      );
}

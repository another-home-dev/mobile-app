enum RoomDesignation {
  male,
  female,
  neutral,
}

class CreateRoomDto {
  final String roomNumber;
  final int capacity;
  final RoomDesignation designation;

  const CreateRoomDto({
    required this.roomNumber,
    required this.capacity,
    required this.designation,
  });

  Map<String, dynamic> toJson() => {
        'roomNumber': roomNumber,
        'capacity': capacity,
        'designation': designation == RoomDesignation.male
            ? 'Male'
            : designation == RoomDesignation.female
                ? 'Female'
                : 'Neutral',
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

class RoomModel {
  final String id;
  final String roomNumber;
  final int capacity;
  final String designation;
  final int currentOccupantsCount;

  const RoomModel({
    required this.id,
    required this.roomNumber,
    required this.capacity,
    required this.designation,
    required this.currentOccupantsCount,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
        id: json['id'] as String,
        roomNumber: json['roomNumber'] as String,
        capacity: json['capacity'] as int,
        designation: json['designation'] as String,
        currentOccupantsCount: json['currentOccupantsCount'] as int? ?? 0,
      );
}

class BedAllocationModel {
  final String id;
  final String studentId;
  final String bedId;
  final DateTime allocatedAt;

  const BedAllocationModel({
    required this.id,
    required this.studentId,
    required this.bedId,
    required this.allocatedAt,
  });

  factory BedAllocationModel.fromJson(Map<String, dynamic> json) =>
      BedAllocationModel(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        bedId: json['bedId'] as String,
        allocatedAt: DateTime.parse(json['allocatedAt'] as String),
      );
}

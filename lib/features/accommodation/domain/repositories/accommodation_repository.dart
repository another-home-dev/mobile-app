import 'package:another_home/core/network/dtos/accommodation_models.dart';

abstract class AccommodationRepository {
  /// Resolves the logged-in student's own record and caches its id locally
  /// for other repositories (finance, notifications, room lookup) to use.
  /// Throws [NotFoundException] if the warden hasn't registered this
  /// student yet.
  Future<StudentModel> getCurrentStudent();

  Future<StudentModel> updateCurrentStudent(Map<String, String> changes);

  /// The student's current room id, asked of the server so a room the warden
  /// assigned after login is seen. Falls back to the cached id when offline.
  Future<String?> currentRoomId();

  /// Throws [StudentNotRegisteredException] if the warden hasn't registered
  /// this student yet. Returns null if registered but not yet allocated a
  /// room.
  Future<RoomModel?> getMyRoom();
}

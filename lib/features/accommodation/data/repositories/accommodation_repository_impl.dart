import 'package:another_home/core/errors/student_not_registered_exception.dart';
import 'package:another_home/core/network/dtos/accommodation_models.dart';
import 'package:another_home/core/network/services/accommodation_api_service.dart';
import 'package:another_home/core/services/secure_storage_service.dart';
import '../../domain/repositories/accommodation_repository.dart';

class AccommodationRepositoryImpl implements AccommodationRepository {
  final AccommodationApiService _apiService;
  final SecureStorageService _secureStorage;

  AccommodationRepositoryImpl(this._apiService, this._secureStorage);

  @override
  Future<StudentModel> getCurrentStudent() async {
    final student = await _apiService.getCurrentStudent();
    await _secureStorage.saveStudentId(student.id);
    return student;
  }

  @override
  Future<StudentModel> updateCurrentStudent(Map<String, String> changes) {
    return _apiService.updateCurrentStudent(changes);
  }

  @override
  Future<RoomModel?> getMyRoom() async {
    final studentId = await _secureStorage.getStudentId();
    if (studentId == null) throw const StudentNotRegisteredException();

    final rooms = await _apiService.getRooms();
    for (final room in rooms) {
      if (room.assignedStudents.any((s) => s.id == studentId)) {
        return room;
      }
    }
    return null;
  }
}

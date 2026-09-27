import 'package:another_home/core/network/dtos/accommodation_models.dart';
import '../repositories/accommodation_repository.dart';

class UpdateStudentProfileUseCase {
  final AccommodationRepository repository;

  UpdateStudentProfileUseCase(this.repository);

  Future<StudentModel> call(Map<String, String> changes) {
    return repository.updateCurrentStudent(changes);
  }
}

import 'package:another_home/core/network/dtos/accommodation_models.dart';
import '../repositories/accommodation_repository.dart';

class GetCurrentStudentUseCase {
  final AccommodationRepository repository;

  GetCurrentStudentUseCase(this.repository);

  Future<StudentModel> call() {
    return repository.getCurrentStudent();
  }
}

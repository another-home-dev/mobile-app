import 'package:another_home/core/network/dtos/operations_models.dart';
import '../repositories/operations_repository.dart';

class RequestVisitorUseCase {
  final OperationsRepository repository;

  RequestVisitorUseCase(this.repository);

  Future<VisitorRequestModel> call({
    required String studentId,
    required String visitorName,
    required String relation,
    required String expectedDate,
  }) {
    return repository.requestVisitor(
      studentId: studentId,
      visitorName: visitorName,
      relation: relation,
      expectedDate: expectedDate,
    );
  }
}

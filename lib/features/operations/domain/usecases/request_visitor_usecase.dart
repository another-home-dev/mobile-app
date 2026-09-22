import 'package:another_home/core/network/dtos/operations_models.dart';
import '../repositories/operations_repository.dart';

class RequestVisitorUseCase {
  final OperationsRepository repository;

  RequestVisitorUseCase(this.repository);

  Future<VisitorRequestModel> call({
    required String roomId,
    required String visitorName,
    required String visitorContact,
    required String purpose,
    required String visitDate,
    required String visitTime,
  }) {
    return repository.requestVisitor(
      roomId: roomId,
      visitorName: visitorName,
      visitorContact: visitorContact,
      purpose: purpose,
      visitDate: visitDate,
      visitTime: visitTime,
    );
  }
}

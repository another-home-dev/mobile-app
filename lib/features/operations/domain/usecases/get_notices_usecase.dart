import 'package:another_home/core/network/dtos/operations_models.dart';
import '../repositories/operations_repository.dart';

class GetNoticesUseCase {
  final OperationsRepository repository;

  GetNoticesUseCase(this.repository);

  Future<List<NoticeModel>> call() {
    return repository.getNotices();
  }
}

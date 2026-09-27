import 'package:another_home/core/network/dtos/accommodation_models.dart';
import '../repositories/accommodation_repository.dart';

class GetMyRoomUseCase {
  final AccommodationRepository repository;

  GetMyRoomUseCase(this.repository);

  Future<RoomModel?> call() {
    return repository.getMyRoom();
  }
}

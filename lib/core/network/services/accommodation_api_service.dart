import '../api_client.dart';
import '../dtos/accommodation_models.dart';

class AccommodationApiService {
  final ApiClient _apiClient;

  AccommodationApiService(this._apiClient);

  /// Get all rooms and their current capacity
  /// GET /accommodation/rooms
  Future<List<RoomModel>> getRooms() async {
    final response = await _apiClient.get('/accommodation/rooms');
    if (response is List) {
      return response
          .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Create a new hostel room
  /// POST /accommodation/rooms
  Future<RoomModel> createRoom(CreateRoomDto createRoomDto) async {
    final response = await _apiClient.post(
      '/accommodation/rooms',
      body: createRoomDto.toJson(),
    );
    return RoomModel.fromJson(response as Map<String, dynamic>);
  }

  /// Assign a student to a specific bed
  /// POST /accommodation/allocations
  Future<BedAllocationModel> allocateBed(AllocateBedDto allocateBedDto) async {
    final response = await _apiClient.post(
      '/accommodation/allocations',
      body: allocateBedDto.toJson(),
    );
    return BedAllocationModel.fromJson(response as Map<String, dynamic>);
  }
}

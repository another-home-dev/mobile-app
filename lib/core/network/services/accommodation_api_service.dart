import '../api_client.dart';
import '../dtos/accommodation_models.dart';

class AccommodationApiService {
  final ApiClient _apiClient;

  AccommodationApiService(this._apiClient);

  /// Resolve the logged-in student's own record (links the Asgardeo account to a
  /// Student by email on first call). Throws NotFoundException if the warden
  /// hasn't registered this student yet.
  /// GET /accommodation/students/me
  Future<StudentModel> getCurrentStudent() async {
    final response = await _apiClient.get('/accommodation/students/me');
    final data = (response as Map<String, dynamic>)['data'];
    return StudentModel.fromJson(data as Map<String, dynamic>);
  }

  /// Update the logged-in student's own profile. Only the keys present in
  /// [changes] are updated; an empty string clears an optional field.
  /// PATCH /accommodation/students/me
  Future<StudentModel> updateCurrentStudent(Map<String, String> changes) async {
    final response = await _apiClient.patch('/accommodation/students/me', body: changes);
    final data = (response as Map<String, dynamic>)['data'];
    return StudentModel.fromJson(data as Map<String, dynamic>);
  }

  /// Get all rooms and their current capacity
  /// GET /accommodation/rooms
  Future<List<RoomModel>> getRooms() async {
    final response = await _apiClient.get('/accommodation/rooms');
    final data = (response as Map<String, dynamic>)['data'];
    if (data is List) {
      return data
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
    final data = (response as Map<String, dynamic>)['data'];
    return RoomModel.fromJson(data as Map<String, dynamic>);
  }

  /// Assign a student to a specific bed
  /// POST /accommodation/allocations
  Future<BedAllocationModel> allocateBed(AllocateBedDto allocateBedDto) async {
    final response = await _apiClient.post(
      '/accommodation/allocations',
      body: allocateBedDto.toJson(),
    );
    final data = (response as Map<String, dynamic>)['data'];
    return BedAllocationModel.fromJson(data as Map<String, dynamic>);
  }
}

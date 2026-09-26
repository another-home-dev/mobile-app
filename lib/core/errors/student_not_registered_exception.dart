/// Thrown by repositories that need the logged-in student's backend id
/// (finance, notifications, room lookup) when the warden hasn't registered
/// this student yet, so no `student_id` has been cached locally.
class StudentNotRegisteredException implements Exception {
  const StudentNotRegisteredException();

  @override
  String toString() => 'StudentNotRegisteredException: student has not been registered by a warden yet';
}

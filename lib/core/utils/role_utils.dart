/// Resolves the app role from an Asgardeo `roles` claim.
///
/// Students register themselves from the Asgardeo login page, and Asgardeo gives
/// self-registered accounts its built-in "selfsignup" role rather than "student",
/// so either one counts as a student. Staff roles take priority, so a warden who
/// also self-registered is still kept out of the student app.
String? resolveAppRole(dynamic roles) {
  final rawList = roles is List
      ? roles
      : (roles == null ? const <dynamic>[] : roles.toString().split(','));

  // Role names can arrive as "student", "Internal/student" or "DEFAULT/student".
  final names = rawList
      .map((r) => r.toString().split('/').last.trim().toLowerCase())
      .where((r) => r.isNotEmpty && r != 'everyone')
      .toSet();

  for (final staffRole in const ['super-admin', 'warden']) {
    if (names.contains(staffRole)) return staffRole;
  }
  if (names.contains('student') || names.contains('selfsignup')) return 'student';
  return names.isEmpty ? null : names.first;
}

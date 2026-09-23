/// Reads a JSON number that the backend may send as a string.
///
/// MySQL DECIMAL columns (room rent, invoice amounts) come back from TypeORM as
/// strings such as "14000.00", so a plain `as num` cast throws.
double parseJsonDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

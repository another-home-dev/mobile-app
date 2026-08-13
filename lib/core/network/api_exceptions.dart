class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class BadRequestException extends ApiException {
  const BadRequestException(super.message, [super.statusCode = 400]);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, [super.statusCode = 401]);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message, [super.statusCode = 403]);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message, [super.statusCode = 404]);
}

class InternalServerErrorException extends ApiException {
  const InternalServerErrorException(super.message, [super.statusCode = 500]);
}

class NetworkException extends ApiException {
  const NetworkException(String message) : super(message, null);
}

abstract class AppException implements Exception {
  final String message;

  const AppException([this.message = 'Ocurrió un error inesperado.']);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([
    super.message =
        'Sin conexión a Internet. Revisa tu red e intenta de nuevo.',
  ]);
}

class ServerException extends AppException {
  const ServerException([
    super.message =
        'Lo sentimos, algo salió mal en nuestros servidores. Inténtalo más tarde.',
  ]);
}

class CacheException extends AppException {
  const CacheException([
    super.message = 'No se pudo acceder a la caché local. Inténtalo de nuevo.',
  ]);
}

class BadRequestException extends ServerException {
  const BadRequestException([
    super.message =
        'La solicitud es inválida. Verifica los datos e intenta nuevamente.',
  ]);
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException([
    super.message =
        'No estás autorizado para realizar esta acción. Ingresa de nuevo.',
  ]);
}

class ForbiddenException extends ServerException {
  const ForbiddenException([
    super.message = 'No tienes permisos para acceder a este recurso.',
  ]);
}

class ConflictException extends AppException {
  const ConflictException([
    super.message = 'La solicitud entra en conflicto con el estado actual.',
  ]);
}

class NotFoundException extends ServerException {
  const NotFoundException([
    super.message = 'No se encontró el recurso solicitado.',
  ]);
}

class InternalServerErrorException extends ServerException {
  const InternalServerErrorException([
    super.message =
        'Lo sentimos, algo salió mal en nuestros servidores. Inténtalo más tarde.',
  ]);
}

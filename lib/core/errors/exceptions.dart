// =============================================================================
// Archivo    : exceptions.dart
// Módulo     : core/errors
// Descripción: Excepciones personalizadas por categoría de fallo.
//              Cada clase cubre una categoría, no un mensaje individual
//              (MPF-OMEGA-04 §6.3.2).
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

// ---------------------------------------------------------------------------
// Errores de red y conectividad
// Cubre: timeout, sin conexión, DNS no resuelto, TLS inválido.
// ---------------------------------------------------------------------------

/// Fallo en la capa de transporte de red.
class NetworkException implements Exception {
  final String mensaje;
  final Object? causa;

  const NetworkException(this.mensaje, {this.causa});

  @override
  String toString() => 'NetworkException: $mensaje';
}

// ---------------------------------------------------------------------------
// Errores de servidor (5xx)
// Cubre: servidor caído, error interno, servicio no disponible.
// ---------------------------------------------------------------------------

/// Fallo en la capa de infraestructura remota (respuestas 5xx).
class ServerException implements Exception {
  final String mensaje;
  final int? codigoHttp;

  const ServerException(this.mensaje, {this.codigoHttp});

  @override
  String toString() => 'ServerException[$codigoHttp]: $mensaje';
}

// ---------------------------------------------------------------------------
// Errores de validación de negocio (400 / 422)
// Cubre: reglas de negocio no cumplidas o formato incorrecto.
// ---------------------------------------------------------------------------

/// Fallo de regla de negocio o formato de datos.
class ValidationException implements Exception {
  final String mensaje;
  final Map<String, String>? erroresCampo;

  const ValidationException(this.mensaje, {this.erroresCampo});

  @override
  String toString() => 'ValidationException: $mensaje';
}

// ---------------------------------------------------------------------------
// Errores de autenticación y sesión (401 / 403)
// Cubre: token expirado, credenciales inválidas, sesión cerrada.
// ---------------------------------------------------------------------------

/// Fallo de identidad o autorización.
class AuthException implements Exception {
  final String mensaje;

  const AuthException(this.mensaje);

  @override
  String toString() => 'AuthException: $mensaje';
}

// ---------------------------------------------------------------------------
// Error de concurrencia — solicitud ya procesada (409)
// ---------------------------------------------------------------------------

/// La solicitud fue procesada por otro autorizador concurrentemente.
class ConcurrenciaException implements Exception {
  final String mensaje;

  const ConcurrenciaException(this.mensaje);

  @override
  String toString() => 'ConcurrenciaException: $mensaje';
}
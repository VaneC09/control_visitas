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


// ── Red / Conectividad ──────────────────────────────────────────────────────
class NetworkException implements Exception {
  final String mensaje;
  final Object? causa;
  const NetworkException(this.mensaje, {this.causa});
  @override
  String toString() => 'NetworkException: $mensaje';
}
 
// ── Servidor 5xx ────────────────────────────────────────────────────────────
class ServerException implements Exception {
  final String mensaje;
  final int? codigoHttp;
  const ServerException(this.mensaje, {this.codigoHttp});
  @override
  String toString() => 'ServerException[$codigoHttp]: $mensaje';
}
 
// ── Validación de negocio (400 / 422) ───────────────────────────────────────
class ValidationException implements Exception {
  final String mensaje;
  final Map<String, String>? erroresCampo;
  const ValidationException(this.mensaje, {this.erroresCampo});
  @override
  String toString() => 'ValidationException: $mensaje';
}
 
// ── Autenticación / Sesión (401 / 403) ──────────────────────────────────────
class AuthException implements Exception {
  final String mensaje;
  const AuthException(this.mensaje);
  @override
  String toString() => 'AuthException: $mensaje';
}
 
// ── Concurrencia: ya procesado (409) ────────────────────────────────────────
class ConcurrenciaException implements Exception {
  final String mensaje;
  const ConcurrenciaException(this.mensaje);
  @override
  String toString() => 'ConcurrenciaException: $mensaje';
}
 
// ── Permisos insuficientes (403) ─────────────────────────────────────────────
class PermisosException implements Exception {
  final String mensaje;
  const PermisosException(this.mensaje);
  @override
  String toString() => 'PermisosException: $mensaje';
}
 
// ── Recurso no encontrado (404) ──────────────────────────────────────────────
class NoEncontradoException implements Exception {
  final String mensaje;
  const NoEncontradoException(this.mensaje);
  @override
  String toString() => 'NoEncontradoException: $mensaje';
}
 
// ── Sin conexión a internet ──────────────────────────────────────────────────
class SinConexionException implements Exception {
  const SinConexionException();
  @override
  String toString() => 'SinConexionException: Sin acceso a Internet';
}
 
// ── Visitante vetado (lista de exclusión) ────────────────────────────────────
class VetoException implements Exception {
  final String mensaje;
  const VetoException(this.mensaje);
  @override
  String toString() => 'VetoException: $mensaje';
}
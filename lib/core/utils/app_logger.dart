// =============================================================================
// Archivo    : app_logger.dart
// Módulo     : core/utils
// Descripción: Sistema centralizado de logs. Clasifica por nivel y evita
//              exponer información sensible. Nunca usa print() directamente
//              (MPF-OMEGA-04 §6.6).
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:logger/logger.dart';

/// Logger institucional del sistema CA.
/// Clasificación: INFO, WARNING, ERROR, CRITICAL.
/// En producción el nivel de verbosidad se reduce.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    // En producción cambiar a Level.warning
    level: Level.trace,
  );

  // ---------------------------------------------------------------------------
  // Métodos de registro por nivel (MPF-OMEGA-04 §6.6.2)
  // ---------------------------------------------------------------------------

  /// Eventos operativos normales — INFO
  static void info(String modulo, String mensaje) {
    _logger.i('[$modulo] $mensaje');
  }

  /// Situaciones anómalas no críticas — WARNING
  static void warning(String modulo, String mensaje) {
    _logger.w('[$modulo] $mensaje');
  }

  /// Fallos controlados que afectan funcionalidad — ERROR
  static void error(String modulo, String mensaje, [Object? excepcion]) {
    _logger.e('[$modulo] $mensaje', error: excepcion);
  }

  /// Fallos que comprometen estabilidad o seguridad — CRITICAL
  static void critical(String modulo, String mensaje, [Object? excepcion]) {
    _logger.f('[$modulo] CRÍTICO: $mensaje', error: excepcion);
  }

  // ---------------------------------------------------------------------------
  // Logs de acciones del usuario (auditoría de UX)
  // ---------------------------------------------------------------------------

  /// Registra acción del autorizador en la UI.
  static void accionUsuario(String accion, {Map<String, dynamic>? contexto}) {
    final detalle = contexto != null ? ' | $contexto' : '';
    _logger.i('[USUARIO] $accion$detalle');
  }

  /// Registra navegación entre pantallas.
  static void navegacion(String destino) {
    _logger.i('[NAV] → $destino');
  }

  /// Registra llamada HTTP (sin datos sensibles).
  static void http(String metodo, String endpoint, int? statusCode) {
    final status = statusCode != null ? ' → $statusCode' : '';
    _logger.d('[HTTP] $metodo $endpoint$status');
  }
}
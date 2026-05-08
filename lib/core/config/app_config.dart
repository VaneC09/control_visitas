// ==============================================================
// Archivo    : app_config.dart
// Módulo     : core/config
// Descripción: Configuración global del entorno de ejecución.
//              Cambia kModoDemo a false cuando el backend esté listo.
// ==============================================================

class AppConfig {
  AppConfig._();

  /// false = producción con backend Laravel real.
  /// Nunca subir true a producción.
  static const bool kModoDemo = false;

  /// URL base del backend Laravel.
  /// Cambia a tu IP o dominio real antes de compilar.
  static const String baseUrl = 'http://192.168.1.100:8080/api';

  /// URL del SAM externo (sistema de autenticación y manejo).
  static const String samUrl = 'http://192.168.1.200:8080/sam/api';

  /// Timeout de conexión en segundos.
  static const int timeoutConexion = 10;

  /// Timeout de respuesta en segundos.
  static const int timeoutRespuesta = 20;
}

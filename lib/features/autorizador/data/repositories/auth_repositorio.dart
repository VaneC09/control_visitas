// =============================================================================
// Archivo    : auth_repositorio.dart
// Módulo     : features/autorizador/data/repositories
// Descripción: Repositorio de autenticación. Gestiona login, logout y
//              persistencia segura del token JWT.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/config/app_routes.dart';

/// Datos del empleado autenticado.
class EmpleadoSesion {
  final int    idEmpleado;
  final String nombre;
  final String apellidoPaterno;
  final String correo;
  final String rol;
  final String departamento;

  const EmpleadoSesion({
    required this.idEmpleado,
    required this.nombre,
    required this.apellidoPaterno,
    required this.correo,
    required this.rol,
    required this.departamento,
  });

  /// Nombre completo del empleado.
  String get nombreCompleto => '$nombre $apellidoPaterno';

  factory EmpleadoSesion.fromJson(Map<String, dynamic> json) {
    return EmpleadoSesion(
      idEmpleado:      json['idEmpleado']    as int?    ?? 0,
      nombre:          json['nombre']        as String? ?? '',
      apellidoPaterno: json['apellidoPaterno'] as String? ?? '',
      correo:          json['correoInstitucional'] as String? ?? '',
      rol:             json['rol']           as String? ?? '',
      departamento:    json['departamento']  as String? ?? '',
    );
  }
}

/// Repositorio de autenticación.
/// Persiste el JWT en [FlutterSecureStorage] para sobrevivir reinicios.
class AuthRepositorio {
  static const String _baseUrl      = 'http://192.168.1.100:8080/ca-backend/api';
  static const String _claveToken   = 'ca_access_token';
  static const String _claveRefresh = 'ca_refresh_token';
  static const String _claveEmpleado = 'ca_empleado_id';

  final FlutterSecureStorage _almacenamiento;
  late final Dio _dio;

  AuthRepositorio({FlutterSecureStorage? almacenamiento})
      : _almacenamiento = almacenamiento ?? const FlutterSecureStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Autentica al empleado y guarda los tokens de forma segura.
  ///
  /// Retorna [EmpleadoSesion] si el login fue exitoso.
  /// Lanza [AuthException] si las credenciales son inválidas.
  /// Lanza [NetworkException] si no hay conectividad.
  Future<EmpleadoSesion> login(String correo, String contrasena) async {
    // =========================================================================
    // MODO DEMO — descomentar cuando el backend esté disponible
    // =========================================================================
    // try {
    //   final respuesta = await _dio.post(
    //     '/auth/login',
    //     data: {'correo': correo, 'contrasena': contrasena},
    //   );
    //   final data = respuesta.data as Map<String, dynamic>;
    //   final accessToken  = data['accessToken']  as String;
    //   final refreshToken = data['refreshToken'] as String;
    //   final empleado = EmpleadoSesion.fromJson(
    //       data['empleado'] as Map<String, dynamic>);
    //
    //   await _almacenamiento.write(key: _claveToken,   value: accessToken);
    //   await _almacenamiento.write(key: _claveRefresh, value: refreshToken);
    //   await _almacenamiento.write(
    //     key: _claveEmpleado, value: empleado.idEmpleado.toString());
    //
    //   AppLogger.info('AuthRepositorio', 'Login exitoso: ${empleado.correo}');
    //   return empleado;
    // } on DioException catch (e) {
    //   if (e.response?.statusCode == 401) {
    //     throw const AuthException('Correo o contraseña incorrectos.');
    //   }
    //   throw NetworkException('Sin conexión. Verifica tu red.', causa: e);
    // }
    // =========================================================================

    // =========================================================================
    // MODO DEMO (MULTI-ROL)
    // =========================================================================
    AppLogger.info('AuthRepositorio', 'Login demo — correo: $correo');
    await Future.delayed(const Duration(milliseconds: 800));

    if (correo.isEmpty || contrasena.isEmpty) {
      throw const AuthException('Correo o contraseña incorrectos.');
    }

    // 🔥 Detectar rol por correo (puedes cambiar la lógica después)
    final esSolicitante = correo.toLowerCase().contains('solicitante');

    final empleado = EmpleadoSesion(
      idEmpleado:      esSolicitante ? 3 : 2,
      nombre:          esSolicitante ? 'Vanessa' : 'Yadhi',
      apellidoPaterno: esSolicitante ? 'Colin' : 'López',
      correo:          correo,
      rol:             esSolicitante ? 'solicitante' : 'autorizador',
      departamento:    'Tecnologías de la Información',
    );

    // Guardar token ficticio para demo
    await _almacenamiento.write(key: _claveToken, value: 'demo_token_2026');
    await _almacenamiento.write(
      key: _claveEmpleado,
      value: empleado.idEmpleado.toString(),
    );

    AppLogger.info(
      'AuthRepositorio',
      'Login exitoso (demo): ${empleado.correo} - Rol: ${empleado.rol}',
    );

    return empleado;
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  /// Elimina los tokens locales y notifica al backend.
  Future<void> logout() async {
    // =========================================================================
    // MODO DEMO
    // =========================================================================
    // try {
    //   final token = await _almacenamiento.read(key: _claveToken);
    //   if (token != null) {
    //     await _dio.post('/auth/logout',
    //       options: Options(headers: {'Authorization': 'Bearer $token'}));
    //   }
    // } catch (_) { /* Ignorar errores al limpiar — el token local siempre se elimina */ }
    // =========================================================================

    await _almacenamiento.delete(key: _claveToken);
    await _almacenamiento.delete(key: _claveRefresh);
    await _almacenamiento.delete(key: _claveEmpleado);
    AppLogger.info('AuthRepositorio', 'Sesión cerrada correctamente');
  }

  // ---------------------------------------------------------------------------
  // Verificar sesión activa
  // ---------------------------------------------------------------------------

  /// Comprueba si hay un token guardado (sesión previa activa).
  Future<bool> haySesionActiva() async {
    final token = await _almacenamiento.read(key: _claveToken);
    return token != null;
  }
}
// ==============================================================
// Archivo    : auth_repositorio.dart
// Módulo     : features/autorizador/data/repositories
// Descripción: Autenticación real contra el SAM externo.
//              El SAM valida usuario/contraseña y devuelve
//              un token JWT + datos del empleado.
// ==============================================================

import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/app_logger.dart';

/// Datos del empleado autenticado provenientes del SAM.
class EmpleadoSesion {
  final int    idEmpleado;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String rol;
  final String departamento;
  final int    idDepartamento;
  final int    idPuesto;

  const EmpleadoSesion({
    required this.idEmpleado,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.rol,
    required this.departamento,
    required this.idDepartamento,
    required this.idPuesto,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno';

  /// El SAM devuelve: { empleado: {...}, token: "...", refreshToken: "..." }
  factory EmpleadoSesion.fromJson(Map<String, dynamic> json) {
    return EmpleadoSesion(
      idEmpleado:      json['id_empleado']      as int?    ?? 0,
      nombre:          json['nombre']            as String? ?? '',
      apellidoPaterno: json['apellidoPa']        as String? ?? '',
      apellidoMaterno: json['apellidoMa']        as String? ?? '',
      correo:          json['correo']            as String? ?? '',
      rol:             json['rol']               as String? ?? '',
      departamento:    json['departamento']      as String? ?? '',
      idDepartamento:  json['id_departamento']   as int?    ?? 0,
      idPuesto:        json['id_puesto']         as int?    ?? 0,
    );
  }
}

class AuthRepositorio {
  final _dio = DioClient.sam;
  final _session = SessionService.instancia;

  /// Autentica al empleado en el SAM.
  /// El SAM espera: { usuario: "...", password: "..." }
  /// El SAM devuelve: { token, refreshToken, empleado: { id_empleado,
  ///   nombre, apellidoPa, apellidoMa, correo, id_puesto,
  ///   id_departamento, departamento { nombre }, puesto { rol } } }
  Future<EmpleadoSesion> login(String usuario, String contrasena) async {
    try {
      AppLogger.accionUsuario('Login SAM', contexto: {'usuario': usuario});
      final resp = await _dio.post('/auth/login', data: {
        'usuario': usuario.trim(),
        'password': contrasena,
      });

      final data = resp.data as Map<String, dynamic>;
      final token        = data['token']        as String;
      final refreshToken = data['refreshToken'] as String?;
      final empleadoJson = data['empleado']     as Map<String, dynamic>;
      final empleado = EmpleadoSesion.fromJson(empleadoJson);

      await _session.guardar(
        token:        token,
        refreshToken: refreshToken,
        idEmpleado:   empleado.idEmpleado,
        rol:          empleado.rol,
        nombre:       empleado.nombreCompleto,
      );

      AppLogger.accionUsuario('Login exitoso',
          contexto: {'id': empleado.idEmpleado, 'rol': empleado.rol});
      return empleado;

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException(
          'Usuario o contraseña incorrectos.',
        );
      }
      throw DioClient.mapearError(e);
    }
  }

  Future<void> logout() async {
    try {
      final token = await _session.leerToken();
      if (token != null) {
        await _dio.post('/auth/logout');
      }
    } catch (_) {
      // Siempre limpiar sesión local, incluso si el backend falla.
    } finally {
      await _session.cerrarSesion();
      AppLogger.accionUsuario('Sesión cerrada');
    }
  }

  Future<bool> haySesionActiva() => _session.haySesionActiva();
}

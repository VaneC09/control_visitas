// =============================================================================
// Archivo    : auth_repositorio_local.dart
// Módulo     : features/autorizador/data/repositories
// Descripción: Repositorio de autenticación en modo local (sin Laravel/SAM).
//              Simula el login del SAM con usuarios demo.
//              Cuando el SAM esté disponible, reemplazar por AuthRepositorioHttp.
// Ruta       : lib/features/autorizador/data/repositories/auth_repositorio_local.dart
// =============================================================================

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/app_logger.dart';

/// Datos del empleado autenticado.
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
  final int    idJefe; // id del autorizador (jefe directo)

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
    required this.idJefe,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno'.trim();

  factory EmpleadoSesion.fromJson(Map<String, dynamic> json) {
    return EmpleadoSesion(
      idEmpleado:      json['id_empleado']      as int?    ?? 0,
      nombre:          json['nombre']           as String? ?? '',
      apellidoPaterno: json['apellidoPa']       as String? ?? '',
      apellidoMaterno: json['apellidoMa']       as String? ?? '',
      correo:          json['correo']           as String? ?? '',
      rol:             json['rol']              as String? ?? '',
      departamento:    json['departamento']     as String? ?? '',
      idDepartamento:  json['id_departamento']  as int?    ?? 0,
      idPuesto:        json['id_puesto']        as int?    ?? 0,
      idJefe:          json['jefe']             as int?    ?? 0,
    );
  }
}

/// Usuarios demo para probar sin backend.
/// En producción, estos datos vienen del SAM.
const List<Map<String, dynamic>> _usuariosDemo = [
  {
    'usuario':        'yadhi.lopez',
    'password':       'Demo1234',
    'id_empleado':    2,
    'nombre':         'Yadhira',
    'apellidoPa':     'Benitez',
    'apellidoMa':     'Millan',
    'correo':         'yadhi.lopez@tec.mx',
    'rol':            'autorizador',
    'departamento':   'Sistemas y Computación',
    'id_departamento':1,
    'id_puesto':      3,
    'jefe':           0,
  },
  {
    'usuario':        'vanessa.colin',
    'password':       'Demo1234',
    'id_empleado':    3,
    'nombre':         'Vanessa',
    'apellidoPa':     'Colin',
    'apellidoMa':     'Gerardo',
    'correo':         'vanessa.colin@tec.mx',
    'rol':            'solicitante',
    'departamento':   'Tecnologías de la Información',
    'id_departamento':2,
    'id_puesto':      4,
    'jefe':           2, // jefe es Yadhira (id=2)
  },
  {
    'usuario':        'j.mora',
    'password':       'Demo1234',
    'id_empleado':    5,
    'nombre':         'Joaquín',
    'apellidoPa':     'Mora',
    'apellidoMa':     'Vega',
    'correo':         'j.mora@tec.mx',
    'rol':            'vigilante',
    'departamento':   'Seguridad',
    'id_departamento':3,
    'id_puesto':      5,
    'jefe':           0,
  },
];

class AuthRepositorioLocal {
  final _session = SessionService.instancia;

  /// Login demo — valida contra la lista de usuarios hardcodeados.
  /// Cuando el SAM esté disponible, reemplazar el cuerpo de este método
  /// por una llamada HTTP a /auth/login.
  Future<EmpleadoSesion> login(String usuario, String contrasena) async {
    // Simula latencia de red
    await Future.delayed(const Duration(milliseconds: 600));

    final match = _usuariosDemo.where(
      (u) => u['usuario'] == usuario.toLowerCase().trim()
          && u['password'] == contrasena,
    ).firstOrNull;

    if (match == null) {
      throw const AuthException('Usuario o contraseña incorrectos.');
    }

    final empleado = EmpleadoSesion.fromJson(match);

    await _session.guardar(
      token:          'demo_token_${empleado.idEmpleado}_${DateTime.now().millisecondsSinceEpoch}',
      idEmpleado:     empleado.idEmpleado,
      rol:            empleado.rol,
      nombre:         empleado.nombreCompleto,
      idDepartamento: empleado.idDepartamento,
      idJefe:         empleado.idJefe,
    );

    AppLogger.accionUsuario('Login exitoso (local)',
        contexto: {'usuario': usuario, 'rol': empleado.rol});
    return empleado;
  }

  Future<void> logout() async {
    await _session.cerrarSesion();
    AppLogger.info('AuthRepositorioLocal', 'Sesión cerrada');
  }

  Future<bool> haySesionActiva() => _session.haySesionActiva();
}
// =============================================================================
// Archivo    : session_service.dart
// Módulo     : core/services
// Ruta       : lib/core/services/session_service.dart
//
// CORRECCIÓN del error:
//   "The constructor being called isn't a const constructor"
//   Causa: SessionService no puede ser const porque tiene FlutterSecureStorage
//   Solución: static final (no const) para el singleton
// =============================================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  // ✅ static final — no const — para el singleton
  static final SessionService instancia = SessionService._internal();

  // Constructor privado nombrado
  SessionService._internal();

  // FlutterSecureStorage sí puede ser const como campo final
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Claves de almacenamiento
  static const String _kToken      = 'ca_access_token';
  static const String _kRefresh    = 'ca_refresh_token';
  static const String _kEmpleadoId = 'ca_empleado_id';
  static const String _kRol        = 'ca_rol';
  static const String _kNombre     = 'ca_nombre';
  static const String _kDeptId     = 'ca_departamento_id';
  static const String _kJefeId     = 'ca_jefe_id';

  /// Guarda todos los datos de sesión de forma segura.
  Future<void> guardar({
    required String token,
    String? refreshToken,
    required int    idEmpleado,
    required String rol,
    required String nombre,
    int? idDepartamento,
    int? idJefe,
  }) async {
    await _storage.write(key: _kToken,      value: token);
    await _storage.write(key: _kEmpleadoId, value: idEmpleado.toString());
    await _storage.write(key: _kRol,        value: rol);
    await _storage.write(key: _kNombre,     value: nombre);
    if (refreshToken != null) {
      await _storage.write(key: _kRefresh, value: refreshToken);
    }
    if (idDepartamento != null) {
      await _storage.write(key: _kDeptId, value: idDepartamento.toString());
    }
    if (idJefe != null) {
      await _storage.write(key: _kJefeId, value: idJefe.toString());
    }
  }

  Future<String?> leerToken()  => _storage.read(key: _kToken);
  Future<String?> leerRol()    => _storage.read(key: _kRol);
  Future<String?> leerNombre() => _storage.read(key: _kNombre);

  Future<int?> leerEmpleadoId() async {
    final v = await _storage.read(key: _kEmpleadoId);
    return v != null ? int.tryParse(v) : null;
  }

  Future<int?> leerDepartamentoId() async {
    final v = await _storage.read(key: _kDeptId);
    return v != null ? int.tryParse(v) : null;
  }

  /// ID del jefe directo del empleado. Usado como autorizador principal.
  Future<int?> leerJefeId() async {
    final v = await _storage.read(key: _kJefeId);
    return v != null ? int.tryParse(v) : null;
  }

  Future<bool> haySesionActiva() async {
    final t = await _storage.read(key: _kToken);
    return t != null && t.isNotEmpty;
  }

  /// Elimina todos los datos de sesión del dispositivo.
  Future<void> cerrarSesion() => _storage.deleteAll();
}
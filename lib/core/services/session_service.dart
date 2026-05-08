// ==============================================================
// Archivo    : session_service.dart
// Módulo     : core/services
// Descripción: Persiste y recupera el token JWT y datos del empleado.
//              Usa FlutterSecureStorage con cifrado nativo.
// ==============================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  static final SessionService instancia = SessionService._internal();
  SessionService._internal();


   final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );


  static const _kToken      = 'ca_access_token';
  static const _kRefresh    = 'ca_refresh_token';
  static const _kEmpleadoId = 'ca_empleado_id';
  static const _kRol        = 'ca_rol';
  static const _kNombre     = 'ca_nombre';
  static const _kDeptId     = 'ca_departamento_id';

  Future<void> guardar({
    required String token,
    String? refreshToken,
    required int idEmpleado,
    required String rol,
    required String nombre,
    int? idDepartamento,
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
  }

  Future<String?> leerToken()      => _storage.read(key: _kToken);
  Future<String?> leerRol()        => _storage.read(key: _kRol);
  Future<String?> leerNombre()     => _storage.read(key: _kNombre);

  Future<int?> leerEmpleadoId() async {
    final v = await _storage.read(key: _kEmpleadoId);
    return v != null ? int.tryParse(v) : null;
  }

  Future<int?> leerDepartamentoId() async {
    final v = await _storage.read(key: _kDeptId);
    return v != null ? int.tryParse(v) : null;
  }

  Future<bool> haySesionActiva() async {
    final t = await _storage.read(key: _kToken);
    return t != null && t.isNotEmpty;
  }

  Future<void> cerrarSesion() => _storage.deleteAll();
}

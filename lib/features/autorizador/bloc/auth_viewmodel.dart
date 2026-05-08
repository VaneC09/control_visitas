// =============================================================================
// Archivo    : auth_viewmodel.dart
// Módulo     : features/autorizador/bloc
// Ruta       : lib/features/autorizador/bloc/auth_viewmodel.dart
// =============================================================================

import 'package:flutter/material.dart';

import 'package:control_visitas/core/errors/exceptions.dart';
import 'package:control_visitas/core/services/session_service.dart';
import 'package:control_visitas/core/utils/app_logger.dart';
import 'package:control_visitas/features/autorizador/data/repositories/auth_repositorio_local.dart';

enum EstadoAuth { inicial, cargando, autenticado, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepositorioLocal _repositorio;

  EstadoAuth     _estado            = EstadoAuth.inicial;
  EstadoAuth     get estado         => _estado;
  EmpleadoSesion? _empleado;
  EmpleadoSesion? get empleado      => _empleado;
  String          _mensajeError     = '';
  String          get mensajeError  => _mensajeError;
  bool            _ocultarContrasena = true;
  bool            get ocultarContrasena => _ocultarContrasena;
  String          _rolSeleccionado  = '';
  String          get rolSeleccionado => _rolSeleccionado;

  AuthViewModel({AuthRepositorioLocal? repositorio})
      : _repositorio = repositorio ?? AuthRepositorioLocal();

  void alternarVisibilidadContrasena() {
    _ocultarContrasena = !_ocultarContrasena;
    notifyListeners();
  }

  void seleccionarRol(String rol) {
    _rolSeleccionado = rol;
    notifyListeners();
  }

  Future<void> login({
    required String correo,
    required String contrasena,
    required VoidCallback onExito,
  }) async {
    if (correo.trim().isEmpty || contrasena.isEmpty) {
      _mensajeError = 'Ingresa tu usuario y contraseña.';
      _estado = EstadoAuth.error;
      notifyListeners();
      return;
    }

    _estado = EstadoAuth.cargando;
    _mensajeError = '';
    notifyListeners();

    try {
      AppLogger.accionUsuario('Login iniciado', contexto: {'usuario': correo});
      _empleado = await _repositorio.login(correo.trim(), contrasena);
      _estado   = EstadoAuth.autenticado;
      notifyListeners();
      onExito();
    } on AuthException catch (e) {
      _mensajeError = e.mensaje;
      _estado = EstadoAuth.error;
      notifyListeners();
    } on NetworkException catch (e) {
      _mensajeError = e.mensaje;
      _estado = EstadoAuth.error;
      notifyListeners();
    } catch (e) {
      _mensajeError = 'Error inesperado. Intenta de nuevo.';
      _estado = EstadoAuth.error;
      AppLogger.error('AuthViewModel', 'Error no controlado', e);
      notifyListeners();
    }
  }

  /// Restaura la sesión desde SecureStorage (usado al iniciar la app).
  Future<void> restaurarSesion() async {
    final session   = SessionService.instancia;
    final haySession = await session.haySesionActiva();
    if (!haySession) return;

    final rol    = await session.leerRol()    ?? '';
    final nombre = await session.leerNombre() ?? '';
    final idEmp  = await session.leerEmpleadoId() ?? 0;

    _empleado = EmpleadoSesion(
      idEmpleado:      idEmp,
      nombre:          nombre,
      apellidoPaterno: '',
      apellidoMaterno: '',
      correo:          '',
      rol:             rol,
      departamento:    '',
      idDepartamento:  0,
      idPuesto:        0,
      idJefe:          0,
    );
    _rolSeleccionado = rol;
    _estado = EstadoAuth.autenticado;
    notifyListeners();
  }

  Future<void> logout() async {
    AppLogger.accionUsuario('Logout');
    await _repositorio.logout();
    _empleado        = null;
    _estado          = EstadoAuth.inicial;
    _rolSeleccionado = '';
    notifyListeners();
  }

  void limpiarError() {
    _mensajeError = '';
    _estado = EstadoAuth.inicial;
    notifyListeners();
  }
}
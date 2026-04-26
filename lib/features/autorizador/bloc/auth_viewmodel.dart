// =============================================================================
// Archivo    : auth_viewmodel.dart
// Módulo     : features/autorizador/bloc
// Descripción: ViewModel de autenticación. Gestiona el estado del login,
//              validación de formulario y ciclo de sesión.
//              Patrón MVVM con Provider.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../data/repositories/auth_repositorio.dart';

/// Estados posibles del proceso de autenticación.
enum EstadoAuth {
  inicial,
  cargando,
  autenticado,
  error,
}

/// ViewModel de autenticación.
/// La vista escucha cambios vía [Consumer<AuthViewModel>] o [context.watch].
class AuthViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Dependencias
  // ---------------------------------------------------------------------------

  final AuthRepositorio _repositorio;

  // ---------------------------------------------------------------------------
  // Estado observable
  // ---------------------------------------------------------------------------

  EstadoAuth _estado = EstadoAuth.inicial;
  EstadoAuth get estado => _estado;

  EmpleadoSesion? _empleado;
  EmpleadoSesion? get empleado => _empleado;

  String _mensajeError = '';
  String get mensajeError => _mensajeError;

  /// Controla visibilidad de la contraseña en el campo de texto.
  bool _ocultarContrasena = true;
  bool get ocultarContrasena => _ocultarContrasena;

  /// Rol seleccionado en la pantalla de selección de rol.
  String _rolSeleccionado = '';
  String get rolSeleccionado => _rolSeleccionado;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  AuthViewModel({AuthRepositorio? repositorio})
      : _repositorio = repositorio ?? AuthRepositorio();

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  /// Alterna visibilidad del campo contraseña.
  void alternarVisibilidadContrasena() {
    _ocultarContrasena = !_ocultarContrasena;
    notifyListeners();
    AppLogger.accionUsuario('Visibilidad contraseña alternada');
  }

  /// Establece el rol seleccionado antes del login.
  void seleccionarRol(String rol) {
    _rolSeleccionado = rol;
    AppLogger.accionUsuario('Rol seleccionado', contexto: {'rol': rol});
    notifyListeners();
  }

  /// Ejecuta el proceso de login completo.
  ///
  /// Valida campos, llama al repositorio y actualiza el estado.
  /// [onExito] se ejecuta si el login fue correcto (para navegar).
  Future<void> login({
    required String correo,
    required String contrasena,
    required VoidCallback onExito,
  }) async {
    // Validación básica antes de llamar a la red
    if (correo.trim().isEmpty || contrasena.isEmpty) {
      _mensajeError = 'Ingresa tu correo y contraseña';
      _estado = EstadoAuth.error;
      notifyListeners();
      return;
    }

    _estado = EstadoAuth.cargando;
    _mensajeError = '';
    notifyListeners();

    try {
      AppLogger.accionUsuario('Intento de login', contexto: {'correo': correo});
      _empleado = await _repositorio.login(correo.trim(), contrasena);
      _estado = EstadoAuth.autenticado;
      notifyListeners();
      onExito();
    } on AuthException catch (e) {
      _mensajeError = e.mensaje;
      _estado = EstadoAuth.error;
      AppLogger.warning('AuthViewModel', 'Login fallido: ${e.mensaje}');
      notifyListeners();
    } on NetworkException catch (e) {
      _mensajeError = e.mensaje;
      _estado = EstadoAuth.error;
      AppLogger.error('AuthViewModel', 'Error de red en login', e);
      notifyListeners();
    } catch (e) {
      _mensajeError = 'Error inesperado. Intenta de nuevo.';
      _estado = EstadoAuth.error;
      AppLogger.error('AuthViewModel', 'Error no controlado en login', e);
      notifyListeners();
    }
  }

  /// Cierra la sesión del empleado autenticado.
  Future<void> logout() async {
    AppLogger.accionUsuario('Logout iniciado');
    await _repositorio.logout();
    _empleado = null;
    _estado = EstadoAuth.inicial;
    _rolSeleccionado = '';
    notifyListeners();
  }

  /// Limpia el mensaje de error para permitir reintento.
  void limpiarError() {
    _mensajeError = '';
    _estado = EstadoAuth.inicial;
    notifyListeners();
  }
}

// =============================================================================
// Archivo    : vigilante_viewmodel.dart
// Módulo     : features/vigilante/bloc
// Descripción: ViewModel único del módulo vigilante. Gestiona autenticación,
//              escaneo QR, visita espontánea, prórroga y visitas del día.
//              Patrón MVVM con Provider (MPF-OMEGA-04 §6.1).
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-27
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../data/models/resultado_escaneo_model.dart';
import '../data/models/vigilante_model.dart';
import '../data/models/visita_hoy_model.dart';
import '../data/repositories/vigilante_repositorio.dart';

/// Estados para operaciones asíncronas del vigilante.
enum EstadoVigilante { inicial, cargando, exitoso, error }

/// Estado específico de la prórroga.
enum EstadoProrroga { inactivo, esperando, aprobada, rechazada, timeout }

/// ViewModel central del módulo vigilante.
class VigilanteViewModel extends ChangeNotifier {
  final VigilanteRepositorio _repositorio;

  VigilanteViewModel({VigilanteRepositorio? repositorio})
      : _repositorio = repositorio ?? VigilanteRepositorio();

  // ---------------------------------------------------------------------------
  // Estado de autenticación
  // ---------------------------------------------------------------------------

  EstadoVigilante _estadoAuth = EstadoVigilante.inicial;
  EstadoVigilante get estadoAuth => _estadoAuth;

  VigilanteModel? _vigilante;
  VigilanteModel? get vigilante => _vigilante;

  bool   _ocultarContrasena = true;
  bool   get ocultarContrasena => _ocultarContrasena;
  String _errorAuth = '';
  String get errorAuth => _errorAuth;

  void alternarContrasena() {
    _ocultarContrasena = !_ocultarContrasena;
    notifyListeners();
  }

  Future<void> login({
    required String correo,
    required String contrasena,
    required String telefono,
    required VoidCallback onExito,
  }) async {
    _estadoAuth = EstadoVigilante.cargando;
    _errorAuth  = '';
    notifyListeners();

    try {
      AppLogger.accionUsuario('Login vigilante', contexto: {'correo': correo});
      _vigilante  = await _repositorio.login(correo, contrasena, telefono);
      _estadoAuth = EstadoVigilante.exitoso;
      notifyListeners();
      onExito();
    } on AuthException catch (e) {
      _errorAuth  = e.mensaje;
      _estadoAuth = EstadoVigilante.error;
      AppLogger.warning('VigilanteViewModel', 'Login fallido: ${e.mensaje}');
      notifyListeners();
    } on NetworkException catch (e) {
      _errorAuth  = e.mensaje;
      _estadoAuth = EstadoVigilante.error;
      notifyListeners();
    } catch (e) {
      _errorAuth  = 'Error inesperado. Intenta de nuevo.';
      _estadoAuth = EstadoVigilante.error;
      AppLogger.error('VigilanteViewModel', 'Error no controlado en login', e);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repositorio.logout();
    _vigilante  = null;
    _estadoAuth = EstadoVigilante.inicial;
    _resultadoEscaneo = null;
    _estadoProrroga   = EstadoProrroga.inactivo;
    notifyListeners();
  }

  void limpiarErrorAuth() {
    _errorAuth  = '';
    _estadoAuth = EstadoVigilante.inicial;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Estado de escaneo QR
  // ---------------------------------------------------------------------------

  EstadoVigilante      _estadoEscaneo = EstadoVigilante.inicial;
  EstadoVigilante      get estadoEscaneo => _estadoEscaneo;
  ResultadoEscaneoModel? _resultadoEscaneo;
  ResultadoEscaneoModel? get resultadoEscaneo => _resultadoEscaneo;

  Future<void> procesarEscaneo(String codigoQr) async {
    _estadoEscaneo = EstadoVigilante.cargando;
    _resultadoEscaneo = null;
    notifyListeners();

    try {
      AppLogger.accionUsuario('QR escaneado', contexto: {'codigo': codigoQr});
      _resultadoEscaneo = await _repositorio.escanear(codigoQr);
      _estadoEscaneo = EstadoVigilante.exitoso;
    } catch (e) {
      _estadoEscaneo = EstadoVigilante.error;
      AppLogger.error('VigilanteViewModel', 'Error en escaneo QR', e);
    }
    notifyListeners();
  }

  void limpiarEscaneo() {
    _resultadoEscaneo = null;
    _estadoEscaneo    = EstadoVigilante.inicial;
    _estadoProrroga   = EstadoProrroga.inactivo;
    _idProrroga       = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Prórroga
  // ---------------------------------------------------------------------------

  EstadoProrroga _estadoProrroga = EstadoProrroga.inactivo;
  EstadoProrroga get estadoProrroga => _estadoProrroga;

  int?  _idProrroga;
  Timer? _timerProrroga;
  int   _segundosEsperaProrroga = 0;
  int   get segundosEsperaProrroga => _segundosEsperaProrroga;

  static const int _maxEsperaSegundos = 180; // 3 minutos máximo

  /// Solicita prórroga y arranca el polling de estado.
  Future<void> solicitarProrroga({required VoidCallback onAprobada}) async {
    if (_resultadoEscaneo?.idQr == null) return;

    _estadoProrroga          = EstadoProrroga.esperando;
    _segundosEsperaProrroga  = 0;
    notifyListeners();

    try {
      _idProrroga = await _repositorio.solicitarProrroga(_resultadoEscaneo!.idQr!);
      AppLogger.info('VigilanteViewModel', 'Prórroga ${_idProrroga} solicitada');
      _iniciarPollingProrroga(onAprobada);
    } catch (e) {
      _estadoProrroga = EstadoProrroga.inactivo;
      AppLogger.error('VigilanteViewModel', 'Error al solicitar prórroga', e);
      notifyListeners();
    }
  }

  void _iniciarPollingProrroga(VoidCallback onAprobada) {
    _timerProrroga = Timer.periodic(const Duration(seconds: 5), (timer) async {
      _segundosEsperaProrroga += 5;

      if (_segundosEsperaProrroga >= _maxEsperaSegundos) {
        timer.cancel();
        _estadoProrroga = EstadoProrroga.timeout;
        notifyListeners();
        return;
      }

      try {
        final estado = await _repositorio.consultarEstadoProrroga(_idProrroga!);
        if (estado == 'aprobada') {
          timer.cancel();
          _estadoProrroga = EstadoProrroga.aprobada;
          notifyListeners();
          onAprobada();
        } else if (estado == 'rechazada') {
          timer.cancel();
          _estadoProrroga = EstadoProrroga.rechazada;
          notifyListeners();
        } else {
          notifyListeners(); // Actualizar contador
        }
      } catch (_) {
        // Ignorar errores de red durante polling — reintenta en el siguiente tick
      }
    });
  }

  void cancelarProrroga() {
    _timerProrroga?.cancel();
    _estadoProrroga = EstadoProrroga.inactivo;
    _idProrroga     = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Visita espontánea
  // ---------------------------------------------------------------------------

  EstadoVigilante _estadoEspontanea = EstadoVigilante.inicial;
  EstadoVigilante get estadoEspontanea => _estadoEspontanea;
  String _errorEspontanea = '';
  String get errorEspontanea => _errorEspontanea;
  Map<String, dynamic>? _resultadoEspontanea;
  Map<String, dynamic>? get resultadoEspontanea => _resultadoEspontanea;

  Future<void> registrarEspontanea({
    required String nombre,
    required String correo,
    required int    idDepartamento,
    required VoidCallback onExito,
  }) async {
    _estadoEspontanea    = EstadoVigilante.cargando;
    _errorEspontanea     = '';
    _resultadoEspontanea = null;
    notifyListeners();

    try {
      AppLogger.accionUsuario('Visita espontánea', contexto: {'correo': correo});
      _resultadoEspontanea = await _repositorio.registrarVisitaEspontanea(
        nombre: nombre, correo: correo, idDepartamento: idDepartamento,
      );
      _estadoEspontanea = EstadoVigilante.exitoso;
      notifyListeners();
      onExito();
    } catch (e) {
      _errorEspontanea  = 'No se pudo registrar la visita. Intenta de nuevo.';
      _estadoEspontanea = EstadoVigilante.error;
      AppLogger.error('VigilanteViewModel', 'Error en visita espontánea', e);
      notifyListeners();
    }
  }

  void limpiarEspontanea() {
    _resultadoEspontanea = null;
    _estadoEspontanea    = EstadoVigilante.inicial;
    _errorEspontanea     = '';
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Visitas del día
  // ---------------------------------------------------------------------------

  EstadoVigilante   _estadoVisitasHoy = EstadoVigilante.inicial;
  EstadoVigilante   get estadoVisitasHoy => _estadoVisitasHoy;
  List<VisitaHoyModel> _visitasHoy = [];
  List<VisitaHoyModel> get visitasHoy => _visitasHoy;
  List<VisitaHoyModel> _visitasFiltradas = [];
  List<VisitaHoyModel> get visitasFiltradas => _visitasFiltradas;
  String _filtroBusqueda = '';

  Future<void> cargarVisitasHoy() async {
    _estadoVisitasHoy = EstadoVigilante.cargando;
    notifyListeners();
    try {
      _visitasHoy = await _repositorio.obtenerVisitasHoy();
      _aplicarFiltro();
      _estadoVisitasHoy = EstadoVigilante.exitoso;
    } catch (e) {
      _estadoVisitasHoy = EstadoVigilante.error;
      AppLogger.error('VigilanteViewModel', 'Error al cargar visitas hoy', e);
    }
    notifyListeners();
  }

  void filtrarVisitas(String texto) {
    _filtroBusqueda = texto;
    _aplicarFiltro();
    notifyListeners();
  }

  void _aplicarFiltro() {
    if (_filtroBusqueda.isEmpty) {
      _visitasFiltradas = List.from(_visitasHoy);
    } else {
      final t = _filtroBusqueda.toLowerCase();
      _visitasFiltradas = _visitasHoy.where((v) =>
        v.nombreVisitante.toLowerCase().contains(t) ||
        v.nombreAnfitrion.toLowerCase().contains(t) ||
        v.departamento.toLowerCase().contains(t) ||
        v.lugarEncuentro.toLowerCase().contains(t)
      ).toList();
    }
  }

  @override
  void dispose() {
    _timerProrroga?.cancel();
    super.dispose();
  }
}

// =============================================================================
// Archivo    : vigilante_viewmodel.dart
// Módulo     : features/vigilante/bloc
// Ruta       : lib/features/vigilante/bloc/vigilante_viewmodel.dart
//
// CORRECCIONES aplicadas:
//   1. Import de auth_repositorio_local con ruta de paquete (no relativa)
//   2. Import de solicitud_repositorio_local con ruta de paquete
//   3. Tipo 'SolicitudRepositorioLocal' con S mayúscula
//   4. Constructor usa 'SolicitudRepositorioLocal()' con mayúscula
//   5. AuthRepositorioLocal importado desde autorizador (no desde vigilante)
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:control_visitas/core/errors/exceptions.dart';
import 'package:control_visitas/core/services/session_service.dart';
import 'package:control_visitas/core/utils/app_logger.dart';

// CORRECCIÓN: rutas absolutas de paquete para el repositorio compartido
import 'package:control_visitas/features/autorizador/data/repositories/auth_repositorio_local.dart';
import 'package:control_visitas/features/autorizador/data/repositories/solicitud_repositorio_local.dart';

import '../data/models/resultado_escaneo_model.dart';
import '../data/models/vigilante_model.dart';
import '../data/models/visita_hoy_model.dart';

enum EstadoVigilante { inicial, cargando, exitoso, error }
enum EstadoProrroga  { inactivo, esperando, aprobada, rechazada, timeout }

class VigilanteViewModel extends ChangeNotifier {

  // CORRECCIÓN: tipo con S mayúscula
  final SolicitudRepositorioLocal _repo;
  final SessionService _session;

  // CORRECCIÓN: constructor con S mayúscula
  VigilanteViewModel()
      : _repo    = SolicitudRepositorioLocal(),
        _session = SessionService.instancia;

  // ── Autenticación ──────────────────────────────────────────────────────────
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
      // CORRECCIÓN: AuthRepositorioLocal importado de autorizador, no de vigilante
      final authRepo = AuthRepositorioLocal();
      final empleado = await authRepo.login(correo.trim(), contrasena);

      if (empleado.rol != 'vigilante') {
        throw const AuthException(
          'Esta cuenta no tiene acceso al módulo de vigilancia.',
        );
      }

      _vigilante = VigilanteModel(
        idVigilante:     empleado.idEmpleado,
        nombre:          empleado.nombre,
        apellidoPaterno: empleado.apellidoPaterno,
        apellidoMaterno: empleado.apellidoMaterno,
        numeroTelefono:  telefono,
        correo:          empleado.correo,
      );

      _estadoAuth = EstadoVigilante.exitoso;
      notifyListeners();
      onExito();

    } on AuthException catch (e) {
      _errorAuth  = e.mensaje;
      _estadoAuth = EstadoVigilante.error;
      notifyListeners();
    } catch (e) {
      _errorAuth  = 'Error inesperado. Intenta de nuevo.';
      _estadoAuth = EstadoVigilante.error;
      AppLogger.error('VigilanteViewModel', 'Error en login', e);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _timerProrroga?.cancel();
    await _session.cerrarSesion();
    _vigilante           = null;
    _estadoAuth          = EstadoVigilante.inicial;
    _resultadoEscaneo    = null;
    _estadoProrroga      = EstadoProrroga.inactivo;
    _resultadoEspontanea = null;
    notifyListeners();
  }

  // ── Escaneo QR ─────────────────────────────────────────────────────────────
  EstadoVigilante        _estadoEscaneo = EstadoVigilante.inicial;
  EstadoVigilante        get estadoEscaneo => _estadoEscaneo;
  ResultadoEscaneoModel? _resultadoEscaneo;
  ResultadoEscaneoModel? get resultadoEscaneo => _resultadoEscaneo;

  Future<void> procesarEscaneo(String codigoQr) async {
    _estadoEscaneo    = EstadoVigilante.cargando;
    _resultadoEscaneo = null;
    notifyListeners();

    try {
      final idVig = await _session.leerEmpleadoId() ?? 0;
      final raw   = await _repo.escanearQr(
        codigoQr:    codigoQr.trim(),
        idVigilante: idVig,
      );

      _resultadoEscaneo = ResultadoEscaneoModel(
        estado:            _mapearEstado(raw['estado'] as String? ?? 'DESCONOCIDO'),
        mensaje:           raw['mensaje']          as String? ?? '',
        horaActual:        raw['horaActual']        as String? ?? '',
        permiteProrroga:   raw['permiteProrroga']   as bool?   ?? false,
        idQr:              raw['idQr']              as int?,
        codigoQr:          codigoQr,
        nombreVisitante:   raw['nombreVisitante']   as String? ?? '',
        correoVisitante:   raw['correoVisitante']   as String? ?? '',
        nombreAnfitrion:   '',
        departamento:      raw['lugarEncuentro']    as String? ?? '',
        fechaVisita:       '',
        horaVisita:        '',
        toleranciaAntes:   15,
        toleranciaDespues: 15,
        idRegistro:            null,
        horaEntradaRegistrada: '',
      );

      _estadoEscaneo = EstadoVigilante.exitoso;
      AppLogger.accionUsuario('QR procesado',
          contexto: {'codigo': codigoQr, 'estado': raw['estado']});

    } catch (e) {
      _estadoEscaneo = EstadoVigilante.error;
      AppLogger.error('VigilanteViewModel', 'Error al procesar QR', e);
    }

    notifyListeners();
  }

  EstadoEscaneo _mapearEstado(String raw) => switch (raw) {
    'VALIDO_ENTRADA'     => EstadoEscaneo.validoEntrada,
    'VALIDO_SALIDA'      => EstadoEscaneo.validoSalida,
    'VENCIDO'            => EstadoEscaneo.vencido,
    'EN_LISTA_EXCLUSION' => EstadoEscaneo.enListaExclusion,
    'YA_UTILIZADO'       => EstadoEscaneo.yaUtilizado,
    'CANCELADO'          => EstadoEscaneo.solicitudCancelada,
    _                    => EstadoEscaneo.desconocido,
  };

  void limpiarEscaneo() {
    _resultadoEscaneo = null;
    _estadoEscaneo    = EstadoVigilante.inicial;
    _estadoProrroga   = EstadoProrroga.inactivo;
    _idProrroga       = null;
    notifyListeners();
  }

  // ── Prórroga (R7) ──────────────────────────────────────────────────────────
  EstadoProrroga _estadoProrroga = EstadoProrroga.inactivo;
  EstadoProrroga get estadoProrroga => _estadoProrroga;

  int?   _idProrroga;
  Timer? _timerProrroga;
  int    _segundosEsperaProrroga = 0;
  int    get segundosEsperaProrroga => _segundosEsperaProrroga;

  static const int _maxEsperaSegundos = 60;

  Future<void> solicitarProrroga({required VoidCallback onAprobada}) async {
    if (_resultadoEscaneo?.idQr == null) return;

    _estadoProrroga         = EstadoProrroga.esperando;
    _segundosEsperaProrroga = 0;
    notifyListeners();

    final idQr  = _resultadoEscaneo!.idQr!;
    _idProrroga = idQr;

    _timerProrroga = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _segundosEsperaProrroga += 3;

      if (_segundosEsperaProrroga >= _maxEsperaSegundos) {
        timer.cancel();
        _estadoProrroga = EstadoProrroga.timeout;
        notifyListeners();
        return;
      }

      try {
        final estado = await _repo.consultarEstadoQr(idQr);
        if (estado == 'extendido') {
          timer.cancel();
          _estadoProrroga = EstadoProrroga.aprobada;
          notifyListeners();
          onAprobada();
        } else {
          notifyListeners();
        }
      } catch (_) {}
    });
  }

  void cancelarProrroga() {
    _timerProrroga?.cancel();
    _estadoProrroga = EstadoProrroga.inactivo;
    _idProrroga     = null;
    notifyListeners();
  }

  // ── Visita espontánea (R11) ────────────────────────────────────────────────
  EstadoVigilante       _estadoEspontanea = EstadoVigilante.inicial;
  EstadoVigilante       get estadoEspontanea => _estadoEspontanea;
  String                _errorEspontanea = '';
  String                get errorEspontanea => _errorEspontanea;
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
      final idVig = await _session.leerEmpleadoId() ?? 0;
      _resultadoEspontanea = await _repo.registrarVisitaEspontanea(
        nombre:         nombre.trim().isEmpty ? 'Visitante' : nombre.trim(),
        correo:         correo.trim().toLowerCase(),
        idDepartamento: idDepartamento,
        idVigilante:    idVig,
      );
      _estadoEspontanea = EstadoVigilante.exitoso;
      notifyListeners();
      onExito();
    } on VetoException catch (e) {
      _errorEspontanea  = e.mensaje;
      _estadoEspontanea = EstadoVigilante.error;
      notifyListeners();
    } catch (e) {
      _errorEspontanea  = 'No se pudo registrar la visita. Intenta de nuevo.';
      _estadoEspontanea = EstadoVigilante.error;
      AppLogger.error('VigilanteViewModel', 'Error visita espontánea', e);
      notifyListeners();
    }
  }

  void limpiarEspontanea() {
    _resultadoEspontanea = null;
    _estadoEspontanea    = EstadoVigilante.inicial;
    _errorEspontanea     = '';
    notifyListeners();
  }

  // ── Visitas del día ────────────────────────────────────────────────────────
  EstadoVigilante      _estadoVisitasHoy = EstadoVigilante.inicial;
  EstadoVigilante      get estadoVisitasHoy => _estadoVisitasHoy;
  List<VisitaHoyModel> _visitasHoy = [];
  List<VisitaHoyModel> get visitasHoy => _visitasHoy;
  List<VisitaHoyModel> _visitasFiltradas = [];
  List<VisitaHoyModel> get visitasFiltradas => _visitasFiltradas;
  String               _filtroBusqueda = '';

  Future<void> cargarVisitasHoy() async {
    _estadoVisitasHoy = EstadoVigilante.cargando;
    notifyListeners();

    try {
      final rawList = await _repo.visitasHoy();
      _visitasHoy = rawList.map((r) => VisitaHoyModel(
        idSolicitud:     r['id_solicitud']        as int?    ?? 0,
        fechaInicio:     r['fecha_inicio']         as String? ?? '',
        estadoSolicitud: r['estado_solicitud']     as String? ?? '',
        tipoSolicitud:   '',
        lugarEncuentro:  r['lugar_encuentro']      as String? ?? '',
        nombreAnfitrion: '',
        departamento:    '',
        idQr:            r['id_qr']               as int?,
        codigoQr:        r['codigo_numerico']      as String? ?? '',
        estadoQr:        r['estado_qr']            as String? ?? '',
        nombreVisitante: '${r["nombre_visitante"] ?? ""} '
                         '${r["apellidos_visitante"] ?? ""}'.trim(),
      )).toList();

      _aplicarFiltro();
      _estadoVisitasHoy = EstadoVigilante.exitoso;
    } catch (e) {
      _estadoVisitasHoy = EstadoVigilante.error;
      AppLogger.error('VigilanteViewModel', 'Error al cargar visitas', e);
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
        v.lugarEncuentro.toLowerCase().contains(t)  ||
        v.codigoQr.toLowerCase().contains(t)
      ).toList();
    }
  }

  @override
  void dispose() {
    _timerProrroga?.cancel();
    super.dispose();
  }
}
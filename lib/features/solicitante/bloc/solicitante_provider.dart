// =============================================================================
// Archivo    : solicitante_provider.dart
// Módulo     : features/solicitante/bloc
// Ruta       : lib/features/solicitante/bloc/solicitante_provider.dart
//
// CORRECCIONES:
//   1. Import con ruta de paquete absoluta
//   2. Tipo 'SolicitudRepositorioLocal' con S mayúscula
//   3. Campo 's.estado' (String) en lugar de 's.idEstadoSolicitud'
//   4. SessionService.instancia (static final, no const)
// =============================================================================

import 'package:flutter/material.dart';

import 'package:control_visitas/core/errors/exceptions.dart';
import 'package:control_visitas/core/services/session_service.dart';
import 'package:control_visitas/core/utils/app_logger.dart';
import 'package:control_visitas/features/autorizador/data/repositories/solicitud_repositorio_local.dart';
import 'package:control_visitas/features/autorizador/data/models/solicitud_model.dart';
import 'package:control_visitas/features/autorizador/data/models/visitante_model.dart';
import 'package:control_visitas/features/solicitante/data/models/solicitud_model.dart';


enum EstadoCarga { inicial, cargando, exito, error }

class SolicitanteProvider extends ChangeNotifier {
  final SolicitudRepositorioLocal _repo;
  final SessionService _session;

  SolicitanteProvider()
      : _repo    = SolicitudRepositorioLocal(),
        _session = SessionService.instancia;

  // ── Listado ───────────────────────────────────────────────────────────────
  EstadoCarga          _estadoLista = EstadoCarga.inicial;
  List<SolicitudModel> _solicitudes = [];
  String               _errorLista  = '';
  EstadoCarga          get estadoLista  => _estadoLista;
  List<SolicitudModel> get solicitudes  => _solicitudes;
  String               get errorLista   => _errorLista;

  // CORRECCIÓN: s.estado es el campo String con el nombre del estado
  List<SolicitudModel> get proximasVisitas => _solicitudes
      .where((s) =>
          s.estado == 'aprobada' &&
          DateTime.tryParse(s.fechaInicio)?.isAfter(DateTime.now()) == true)
      .toList();

  List<SolicitudModel> get todasSolicitudes => _solicitudes;

  // ── Detalle ───────────────────────────────────────────────────────────────
  EstadoCarga     _estadoDetalle    = EstadoCarga.inicial;
  SolicitudModel? _solicitudDetalle;
  String          _errorDetalle     = '';
  EstadoCarga     get estadoDetalle    => _estadoDetalle;
  SolicitudModel? get solicitudDetalle => _solicitudDetalle;
  String          get errorDetalle     => _errorDetalle;

  // ── Visitantes frecuentes ─────────────────────────────────────────────────
  List<Map<String, dynamic>> _visitantesFrecuentes = [];
  List<Map<String, dynamic>> get visitantesFrecuentes => _visitantesFrecuentes;

  // ── Wizard ────────────────────────────────────────────────────────────────
  int    _pasoActual        = 0;
  String _tipoVisita        = 'individual';
  List<VisitanteModel> _visitantes = [
    const VisitanteModel(nombre: '', apellidos: '', correoPersonal: ''),
  ];
  String     _motivoVisita      = '';
  String     _lugarEncuentro    = '';
  DateTime?  _fechaVisita;
  TimeOfDay? _horaVisita;
  int    _toleranciaMinutos = 15;
  bool   _enviando          = false;
  String _errorCrear        = '';
  bool   _creacionExitosa   = false;

  int          get pasoActual        => _pasoActual;
  String       get tipoVisita        => _tipoVisita;
  List<VisitanteModel> get visitantes => _visitantes;
  String       get motivoVisita      => _motivoVisita;
  String       get lugarEncuentro    => _lugarEncuentro;
  DateTime?    get fechaVisita       => _fechaVisita;
  TimeOfDay?   get horaVisita        => _horaVisita;
  int          get toleranciaMinutos => _toleranciaMinutos;
  bool         get enviando          => _enviando;
  String       get errorCrear        => _errorCrear;
  bool         get creacionExitosa   => _creacionExitosa;

  // ── Catálogos ─────────────────────────────────────────────────────────────
  List<CatalogoModel> _motivos = [];
  List<CatalogoModel> _lugares = [];
  List<CatalogoModel> get motivos => _motivos;
  List<CatalogoModel> get lugares => _lugares;

  // ══════════════════════════════════════════════════════════════════════════
  // LISTADO
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> cargarSolicitudes() async {
    _estadoLista = EstadoCarga.cargando;
    _errorLista  = '';
    notifyListeners();
    try {
      final idEmp  = await _session.leerEmpleadoId() ?? 0;
      _solicitudes = await _repo.obtenerMisSolicitudes(idEmp);
      _estadoLista = EstadoCarga.exito;
    } catch (e) {
      _errorLista  = _mensajeError(e);
      _estadoLista = EstadoCarga.error;
      AppLogger.error('SolicitanteProvider', 'Error cargar solicitudes', e);
    }
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DETALLE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> cargarDetalle(int idSolicitud) async {
    _estadoDetalle = EstadoCarga.cargando;
    _errorDetalle  = '';
    notifyListeners();
    try {
      _solicitudDetalle = _solicitudes.firstWhere(
        (s) => s.idSolicitud == idSolicitud,
        orElse: () => throw const NoEncontradoException('Solicitud no encontrada.'),
      );
      _estadoDetalle = EstadoCarga.exito;
    } catch (e) {
      _errorDetalle  = _mensajeError(e);
      _estadoDetalle = EstadoCarga.error;
    }
    notifyListeners();
  }

  Future<bool> cancelarSolicitud(int idSolicitud) async {
    try {
      await _repo.cancelar(idSolicitud);
      await cargarSolicitudes();
      return true;
    } catch (e) {
      _errorDetalle = _mensajeError(e);
      notifyListeners();
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VISITANTES FRECUENTES (R2)
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> cargarVisitantesFrecuentes() async {
    try {
      final idEmp = await _session.leerEmpleadoId() ?? 0;
      _visitantesFrecuentes = await _repo.visitantesFrecuentes(idEmp);
      notifyListeners();
    } catch (_) {}
  }

  void usarVisitanteFrecuente(int index, Map<String, dynamic> datos) {
    actualizarVisitante(index, VisitanteModel(
      idVisitante:    datos['id_visitante']    as int?    ?? 0,
      nombre:         datos['nombre']          as String? ?? '',
      apellidos:      datos['apellidos']       as String? ?? '',
      correoPersonal: datos['correo_personal'] as String? ?? '',
    ));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIZARD
  // ══════════════════════════════════════════════════════════════════════════

  void avanzarPaso()   { if (_pasoActual < 2) { _pasoActual++; notifyListeners(); } }
  void retrocederPaso(){ if (_pasoActual > 0) { _pasoActual--; notifyListeners(); } }

  void setTipoVisita(String tipo) {
    _tipoVisita = tipo;
    if (tipo == 'individual') {
      _visitantes = [const VisitanteModel(nombre: '', apellidos: '', correoPersonal: '')];
    }
    notifyListeners();
  }

  void actualizarVisitante(int index, VisitanteModel v) {
    if (index < _visitantes.length) {
      _visitantes = List.from(_visitantes)..[index] = v;
      notifyListeners();
    }
  }

  void agregarVisitante() {
    _visitantes = [..._visitantes,
      const VisitanteModel(nombre: '', apellidos: '', correoPersonal: '')];
    notifyListeners();
  }

  void eliminarVisitante(int index) {
    if (_visitantes.length > 1) {
      _visitantes = List.from(_visitantes)..removeAt(index);
      notifyListeners();
    }
  }

  void setMotivoVisita(String v)    { _motivoVisita   = v; notifyListeners(); }
  void setLugarEncuentro(String v)  { _lugarEncuentro = v; notifyListeners(); }
  void setFechaVisita(DateTime v)   { _fechaVisita    = v; notifyListeners(); }
  void setHoraVisita(TimeOfDay v)   { _horaVisita     = v; notifyListeners(); }
  void setTolerancia(int v)         { _toleranciaMinutos = v; notifyListeners(); }

  Future<void> enviarSolicitud() async {
    if (_fechaVisita == null || _horaVisita == null) return;
    _enviando = true; _errorCrear = ''; _creacionExitosa = false;
    notifyListeners();

    try {
      final idEmp  = await _session.leerEmpleadoId() ?? 0;
      final idJefe = await _session.leerJefeId() ?? 0;

      final visLst = _visitantes.map((v) => {
        'nombre':    v.nombre,
        'apellidos': v.apellidos,
        'correo':    v.correoPersonal,
      }).toList();

      final fecha = DateTime(
        _fechaVisita!.year, _fechaVisita!.month, _fechaVisita!.day,
        _horaVisita!.hour,  _horaVisita!.minute,
      );

      await _repo.crearSolicitud(
        fechaInicio:       fecha,
        toleranciaAntes:   _toleranciaMinutos,
        toleranciaDespues: _toleranciaMinutos,
        lugarEncuentro:    _lugarEncuentro,
        motivoVisita:      _motivoVisita,
        idTipoSolicitud:   _tipoVisita == 'grupal' ? 4 : 1,
        idAutorizador:     idJefe,
        idAutorizadorAlt:  99,
        idSolicitante:     idEmp,
        visitantes:        visLst,
      );

      _creacionExitosa = true;
      await cargarSolicitudes();
    } on VetoException catch (e)       { _errorCrear = e.mensaje; }
      on ValidationException catch (e) { _errorCrear = e.mensaje; }
      catch (e) {
      _errorCrear = _mensajeError(e);
      AppLogger.error('SolicitanteProvider', 'Error crear solicitud', e);
    }

    _enviando = false;
    notifyListeners();
  }

  void iniciarNuevaSolicitud() {
    _pasoActual = 0; _tipoVisita = 'individual';
    _visitantes = [const VisitanteModel(nombre: '', apellidos: '', correoPersonal: '')];
    _motivoVisita = ''; _lugarEncuentro = '';
    _fechaVisita = null; _horaVisita = null;
    _toleranciaMinutos = 15; _creacionExitosa = false; _errorCrear = '';
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CATÁLOGOS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> cargarCatalogos() async {
    _motivos = [
      const CatalogoModel(id: '1', nombre: 'Reunión de trabajo'),
      const CatalogoModel(id: '2', nombre: 'Entrevista laboral'),
      const CatalogoModel(id: '3', nombre: 'Entrega de documentos'),
      const CatalogoModel(id: '4', nombre: 'Auditoría'),
      const CatalogoModel(id: '5', nombre: 'Revisión de proyecto'),
      const CatalogoModel(id: '6', nombre: 'Consulta académica'),
      const CatalogoModel(id: '7', nombre: 'Otro'),
    ];
    _lugares = [
      const CatalogoModel(id: '1', nombre: 'Edificio A — Administración'),
      const CatalogoModel(id: '2', nombre: 'Edificio B — Aulas'),
      const CatalogoModel(id: '3', nombre: 'Edificio C — Laboratorios'),
      const CatalogoModel(id: '4', nombre: 'Sistemas y Computación'),
      const CatalogoModel(id: '5', nombre: 'Recursos Humanos'),
      const CatalogoModel(id: '6', nombre: 'Dirección General'),
      const CatalogoModel(id: '7', nombre: 'Alberca'),
    ];
    notifyListeners();
  }

  String _mensajeError(Object e) {
    if (e is VetoException)         return e.mensaje;
    if (e is ValidationException)   return e.mensaje;
    if (e is NoEncontradoException) return e.mensaje;
    if (e is ConcurrenciaException) return e.mensaje;
    if (e is SinConexionException)  return 'Sin conexión.';
    if (e is AuthException)         return e.mensaje;
    return 'Error inesperado. Intenta de nuevo.';
  }
}
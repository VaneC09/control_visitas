// =============================================================================
// Archivo: solicitante_provider.dart
// Módulo: solicitante/bloc
// Descripción: ViewModel/Provider que gestiona el estado del módulo solicitante.
// Autor: Vanessa Fernanda Colin Gerardo
// Versión: 1.0
// Fecha: 2026-04-26
// =============================================================================

import 'package:flutter/material.dart';
import '../data/models/solicitud_model.dart';
import '../data/repositories/solicitante_repositorio.dart';

/// Estados posibles de carga.
enum EstadoCarga { inicial, cargando, exito, error }

/// Provider que gestiona el estado del módulo Solicitante (MVVM ViewModel).
class SolicitanteProvider extends ChangeNotifier {
  final SolicitanteRepositorio _repositorio;

  SolicitanteProvider() : _repositorio = SolicitanteRepositorio();

  // ---------------------------------------------------------------------------
  // Estado - Listado de solicitudes
  // ---------------------------------------------------------------------------
  EstadoCarga _estadoLista = EstadoCarga.inicial;
  List<SolicitudModel> _solicitudes = [];
  String _errorLista = '';

  EstadoCarga get estadoLista => _estadoLista;
  List<SolicitudModel> get solicitudes => _solicitudes;
  String get errorLista => _errorLista;

  List<SolicitudModel> get proximasVisitas => _solicitudes
      .where((s) =>
          s.idEstadoSolicitud == 'aprobada' &&
          DateTime.tryParse(s.fechaInicio)?.isAfter(DateTime.now()) == true)
      .toList();

  List<SolicitudModel> get todasSolicitudes => _solicitudes;

  // ---------------------------------------------------------------------------
  // Estado - Detalle
  // ---------------------------------------------------------------------------
  EstadoCarga _estadoDetalle = EstadoCarga.inicial;
  SolicitudModel? _solicitudDetalle;
  String _errorDetalle = '';

  EstadoCarga get estadoDetalle => _estadoDetalle;
  SolicitudModel? get solicitudDetalle => _solicitudDetalle;
  String get errorDetalle => _errorDetalle;

  // ---------------------------------------------------------------------------
  // Estado - Nueva solicitud (wizard 3 pasos)
  // ---------------------------------------------------------------------------
  int _pasoActual = 0;
  String _tipoVisita = 'individual';
  List<VisitanteModel> _visitantes = [
    const VisitanteModel(nombre: '', apellidos: '', correoPersonal: ''),
  ];
  String _motivoVisita = '';
  String _lugarEncuentro = '';
  DateTime? _fechaVisita;
  TimeOfDay? _horaVisita;
  int _toleranciaMinutos = 15;
  bool _enviando = false;
  String _errorCrear = '';
  bool _creacionExitosa = false;

  int get pasoActual => _pasoActual;
  String get tipoVisita => _tipoVisita;
  List<VisitanteModel> get visitantes => _visitantes;
  String get motivoVisita => _motivoVisita;
  String get lugarEncuentro => _lugarEncuentro;
  DateTime? get fechaVisita => _fechaVisita;
  TimeOfDay? get horaVisita => _horaVisita;
  int get toleranciaMinutos => _toleranciaMinutos;
  bool get enviando => _enviando;
  String get errorCrear => _errorCrear;
  bool get creacionExitosa => _creacionExitosa;

  // ---------------------------------------------------------------------------
  // Estado - Catálogos
  // ---------------------------------------------------------------------------
  List<CatalogoModel> _motivos = [];
  List<CatalogoModel> _lugares = [];

  List<CatalogoModel> get motivos => _motivos;
  List<CatalogoModel> get lugares => _lugares;

  // ---------------------------------------------------------------------------
  // Acciones - Listado
  // ---------------------------------------------------------------------------

  /// Carga las solicitudes del solicitante (datos mock para desarrollo).
  Future<void> cargarSolicitudes() async {
    _estadoLista = EstadoCarga.cargando;
    _errorLista = '';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    _solicitudes = [
      SolicitudModel(
        idSolicitud: 1,
        fechaInicio: DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String(),
        toleranciaAntes: 15,
        toleranciaDespues: 15,
        prorrogaTolerancias: false,
        idEstadoSolicitud: 'aprobada',
        nombreEstado: 'Autorizada',
        idTipoSolicitud: '1',
        idLugarEncuentro: '1',
        idMotivoVisita: '1',
        descripcionMotivo: 'Reunión de proyecto',
        visitantes: const [
          VisitanteModel(
            idVisitante: 1,
            nombre: 'Juan',
            apellidos: 'Pérez García',
            correoPersonal: 'juan@correo.com',
          ),
        ],
      ),
      SolicitudModel(
        idSolicitud: 2,
        fechaInicio: DateTime.now()
            .add(const Duration(days: 2))
            .toIso8601String(),
        toleranciaAntes: 15,
        toleranciaDespues: 15,
        prorrogaTolerancias: false,
        idEstadoSolicitud: 'pendiente',
        nombreEstado: 'Pendiente',
        idTipoSolicitud: '1',
        idLugarEncuentro: '1',
        idMotivoVisita: '2',
        descripcionMotivo: 'Entrevista laboral',
        visitantes: const [
          VisitanteModel(
            idVisitante: 2,
            nombre: 'María',
            apellidos: 'López Sánchez',
            correoPersonal: 'maria@correo.com',
          ),
        ],
      ),
      SolicitudModel(
        idSolicitud: 3,
        fechaInicio: DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        toleranciaAntes: 15,
        toleranciaDespues: 15,
        prorrogaTolerancias: false,
        idEstadoSolicitud: 'cancelada',
        nombreEstado: 'Cancelada',
        idTipoSolicitud: '1',
        idLugarEncuentro: '1',
        idMotivoVisita: '1',
        descripcionMotivo: 'Auditoría anual',
        visitantes: const [
          VisitanteModel(
            idVisitante: 3,
            nombre: 'Carlos',
            apellidos: 'Ruiz Díaz',
            correoPersonal: 'carlos@correo.com',
          ),
        ],
      ),
    ];

    _estadoLista = EstadoCarga.exito;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Acciones - Detalle
  // ---------------------------------------------------------------------------

  /// Carga el detalle de una solicitud específica.
  Future<void> cargarDetalle(int idSolicitud) async {
    _estadoDetalle = EstadoCarga.cargando;
    _errorDetalle = '';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _solicitudDetalle = _solicitudes.firstWhere(
      (s) => s.idSolicitud == idSolicitud,
      orElse: () => _solicitudes.first,
    );
    _estadoDetalle = EstadoCarga.exito;
    notifyListeners();
  }

  /// Cancela una solicitud y recarga la lista.
  Future<bool> cancelarSolicitud(int idSolicitud) async {
    try {
      await cargarSolicitudes();
      return true;
    } catch (e) {
      _errorDetalle = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Acciones - Wizard nueva solicitud
  // ---------------------------------------------------------------------------

  void avanzarPaso() {
    if (_pasoActual < 2) {
      _pasoActual++;
      notifyListeners();
    }
  }

  void retrocederPaso() {
    if (_pasoActual > 0) {
      _pasoActual--;
      notifyListeners();
    }
  }

  void setTipoVisita(String tipo) {
    _tipoVisita = tipo;
    if (tipo == 'individual') {
      _visitantes = [
        const VisitanteModel(nombre: '', apellidos: '', correoPersonal: ''),
      ];
    }
    notifyListeners();
  }

  void actualizarVisitante(int index, VisitanteModel visitante) {
    if (index < _visitantes.length) {
      _visitantes = List.from(_visitantes)..[index] = visitante;
      notifyListeners();
    }
  }

  void agregarVisitante() {
    _visitantes = [
      ..._visitantes,
      const VisitanteModel(nombre: '', apellidos: '', correoPersonal: ''),
    ];
    notifyListeners();
  }

  void eliminarVisitante(int index) {
    if (_visitantes.length > 1) {
      _visitantes = List.from(_visitantes)..removeAt(index);
      notifyListeners();
    }
  }

  void setMotivoVisita(String motivo) {
    _motivoVisita = motivo;
    notifyListeners();
  }

  void setLugarEncuentro(String lugar) {
    _lugarEncuentro = lugar;
    notifyListeners();
  }

  void setFechaVisita(DateTime fecha) {
    _fechaVisita = fecha;
    notifyListeners();
  }

  void setHoraVisita(TimeOfDay hora) {
    _horaVisita = hora;
    notifyListeners();
  }

  void setTolerancia(int minutos) {
    _toleranciaMinutos = minutos;
    notifyListeners();
  }

  /// Envía la solicitud (mock para desarrollo).
  Future<void> enviarSolicitud() async {
  if (_fechaVisita == null || _horaVisita == null) return;

  _enviando = true;
  _errorCrear = '';
  _creacionExitosa = false;
  notifyListeners();

  await Future.delayed(const Duration(milliseconds: 800));

  _creacionExitosa = true;

  await cargarSolicitudes();

  _enviando = false;
  notifyListeners();
}

  void _resetearWizard() {
    _pasoActual = 0;
    _tipoVisita = 'individual';
    _visitantes = [
      const VisitanteModel(nombre: '', apellidos: '', correoPersonal: ''),
    ];
    _motivoVisita = '';
    _lugarEncuentro = '';
    _fechaVisita = null;
    _horaVisita = null;
    _toleranciaMinutos = 15;
    _creacionExitosa = false;
  }

  void iniciarNuevaSolicitud() {
    _resetearWizard();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Acciones - Catálogos
  // ---------------------------------------------------------------------------

  Future<void> cargarCatalogos() async {
    // Mock de catálogos para desarrollo
    _motivos = [
      const CatalogoModel(id: '1', nombre: 'Reunión de trabajo'),
      const CatalogoModel(id: '2', nombre: 'Entrevista laboral'),
      const CatalogoModel(id: '3', nombre: 'Entrega de documentos'),
      const CatalogoModel(id: '4', nombre: 'Auditoría'),
      const CatalogoModel(id: '5', nombre: 'Otro'),
    ];
    _lugares = [
      const CatalogoModel(id: '1', nombre: 'Edificio A'),
      const CatalogoModel(id: '2', nombre: 'Edificio B'),
      const CatalogoModel(id: '3', nombre: 'Edificio C'),
      const CatalogoModel(id: '4', nombre: 'Edificio D'),
    ];
    notifyListeners();
  }
}
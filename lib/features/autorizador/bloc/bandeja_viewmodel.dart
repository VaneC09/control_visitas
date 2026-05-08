// =============================================================================
// Archivo    : bandeja_viewmodel.dart
// Módulo     : features/autorizador/bloc
// Descripción: ViewModel de la bandeja de solicitudes pendientes.
//              Gestiona carga, filtrado, aprobación y rechazo de solicitudes.
//              Patrón MVVM con Provider.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================


import 'package:flutter/material.dart';
 
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../data/models/solicitud_model.dart';
import '../data/repositories/solicitud_repositorio_local.dart';
 
/// Estados posibles de la bandeja.
enum EstadoBandeja {
  inicial,
  cargando,
  conDatos,
  vacio,
  error,
  procesando,
}
 
class BandejaViewModel extends ChangeNotifier {
  // ── Dependencias ────────────────────────────────────────────────────────────
  final SolicitudRepositorioLocal _repositorio;
 
  // ── Estado observable ────────────────────────────────────────────────────────
  EstadoBandeja _estado = EstadoBandeja.inicial;
  EstadoBandeja get estado => _estado;
 
  List<SolicitudModel> _todasLasSolicitudes = [];
  List<SolicitudModel> _solicitudesFiltradas = [];
  List<SolicitudModel> get solicitudesFiltradas => _solicitudesFiltradas;
 
  String _mensajeError = '';
  String get mensajeError => _mensajeError;
 
  String _textoBusqueda = '';
  String get textoBusqueda => _textoBusqueda;
 
  int _filtroActivo = 0;
  int get filtroActivo => _filtroActivo;
 
  int? _idProcesando;
  int? get idProcesando => _idProcesando;
 
  // ── Constructor ──────────────────────────────────────────────────────────────
  BandejaViewModel({SolicitudRepositorioLocal? repositorio})
      : _repositorio = repositorio ?? SolicitudRepositorioLocal();
 
  // ── Cargar ───────────────────────────────────────────────────────────────────
  Future<void> cargarSolicitudes() async {
    _estado = EstadoBandeja.cargando;
    _mensajeError = '';
    notifyListeners();
 
    try {
      AppLogger.accionUsuario('Cargando bandeja');
      _todasLasSolicitudes = await _repositorio.obtenerPendientes();
      _aplicarFiltros();
      _estado = _solicitudesFiltradas.isEmpty
          ? EstadoBandeja.vacio
          : EstadoBandeja.conDatos;
    } catch (e) {
      _mensajeError = _mensajeParaUsuario(e);
      _estado = EstadoBandeja.error;
      AppLogger.error('BandejaViewModel', 'Error al cargar', e);
    }
 
    notifyListeners();
  }
 
  // ── Filtros ──────────────────────────────────────────────────────────────────
  void buscar(String texto) {
    _textoBusqueda = texto;
    _aplicarFiltros();
    notifyListeners();
  }
 
  void cambiarFiltro(int indice) {
    _filtroActivo = indice;
    _aplicarFiltros();
    notifyListeners();
  }
 
  void _aplicarFiltros() {
    var lista = List<SolicitudModel>.from(_todasLasSolicitudes);
 
    const estados = ['', 'pendiente', 'aprobada', 'rechazada'];
    if (_filtroActivo > 0 && _filtroActivo < estados.length) {
      final estadoFiltro = estados[_filtroActivo];
      lista = lista.where((s) => s.estado == estadoFiltro).toList();
    }
 
    if (_textoBusqueda.isNotEmpty) {
      final q = _textoBusqueda.toLowerCase();
      lista = lista.where((s) {
        return s.nombreSolicitante.toLowerCase().contains(q) ||
            s.motivoVisita.toLowerCase().contains(q) ||
            s.visitantes.any(
              (v) => v.nombreCompleto.toLowerCase().contains(q),
            );
      }).toList();
    }
 
    _solicitudesFiltradas = lista;
  }
 
  // ── Aprobar ──────────────────────────────────────────────────────────────────
  Future<void> aprobar({
    required int idSolicitud,
    required VoidCallback onExito,
    required void Function(String) onError,
  }) async {
    _idProcesando = idSolicitud;
    _estado = EstadoBandeja.procesando;
    notifyListeners();
 
    try {
      await _repositorio.aprobar(idSolicitud);
 
      _todasLasSolicitudes.removeWhere((s) => s.idSolicitud == idSolicitud);
      _aplicarFiltros();
      _estado = _solicitudesFiltradas.isEmpty
          ? EstadoBandeja.vacio
          : EstadoBandeja.conDatos;
      _idProcesando = null;
      notifyListeners();
      onExito();
    } on ConcurrenciaException catch (e) {
      _estado = EstadoBandeja.conDatos;
      _idProcesando = null;
      notifyListeners();
      onError(e.mensaje);
    } catch (e) {
      _estado = EstadoBandeja.conDatos;
      _idProcesando = null;
      notifyListeners();
      onError(_mensajeParaUsuario(e));
    }
  }
 
  // ── Rechazar ─────────────────────────────────────────────────────────────────
  Future<void> rechazar({
    required int idSolicitud,
    required VoidCallback onExito,
    required void Function(String) onError,
    String? motivo,
  }) async {
    _idProcesando = idSolicitud;
    _estado = EstadoBandeja.procesando;
    notifyListeners();
 
    try {
      await _repositorio.rechazar(idSolicitud, motivo: motivo);
 
      _todasLasSolicitudes.removeWhere((s) => s.idSolicitud == idSolicitud);
      _aplicarFiltros();
      _estado = _solicitudesFiltradas.isEmpty
          ? EstadoBandeja.vacio
          : EstadoBandeja.conDatos;
      _idProcesando = null;
      notifyListeners();
      onExito();
    } on ConcurrenciaException catch (e) {
      _estado = EstadoBandeja.conDatos;
      _idProcesando = null;
      notifyListeners();
      onError(e.mensaje);
    } catch (e) {
      _estado = EstadoBandeja.conDatos;
      _idProcesando = null;
      notifyListeners();
      onError(_mensajeParaUsuario(e));
    }
  }
 
  void limpiarError() {
    _mensajeError = '';
    _estado = EstadoBandeja.inicial;
    notifyListeners();
  }
 
  String _mensajeParaUsuario(Object e) {
    if (e is ValidationException)   return e.mensaje;
    if (e is ConcurrenciaException) return e.mensaje;
    if (e is NoEncontradoException) return e.mensaje;
    if (e is SinConexionException)  return 'Sin conexión. Verifica tu red.';
    if (e is AuthException)         return e.mensaje;
    return 'Ocurrió un error. Intenta de nuevo.';
  }
}
 
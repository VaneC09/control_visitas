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
import '../../../../core/utils/app_logger.dart';
import '../data/models/solicitud_model.dart';
import '../data/repositories/solicitud_repositorio.dart';

/// Estados posibles de la bandeja de solicitudes.
enum EstadoBandeja {
  inicial,
  cargando,
  conDatos,
  vacio,
  error,
  procesando,  // Aprobar/rechazar en curso
}

/// ViewModel de la bandeja del autorizador.
/// Mantiene la lista filtrada y el estado de cada acción.
class BandejaViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Dependencias
  // ---------------------------------------------------------------------------

  final SolicitudRepositorio _repositorio;

  // ---------------------------------------------------------------------------
  // Estado observable
  // ---------------------------------------------------------------------------

  EstadoBandeja _estado = EstadoBandeja.inicial;
  EstadoBandeja get estado => _estado;

  /// Lista completa sin filtrar (fuente de verdad).
  List<SolicitudModel> _todasLasSolicitudes = [];

  /// Lista que se muestra tras aplicar filtros.
  List<SolicitudModel> _solicitudesFiltradas = [];
  List<SolicitudModel> get solicitudesFiltradas => _solicitudesFiltradas;

  String _mensajeError = '';
  String get mensajeError => _mensajeError;

  /// Texto del buscador libre.
  String _textoBusqueda = '';
  String get textoBusqueda => _textoBusqueda;

  /// Índice del filtro de estado activo (0=Todos, 1=Pendientes, 2=Aprobados, 3=Rechazados).
  int _filtroActivo = 0;
  int get filtroActivo => _filtroActivo;

  /// ID de la solicitud que se está procesando actualmente.
  int? _idProcesando;
  int? get idProcesando => _idProcesando;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  BandejaViewModel({SolicitudRepositorio? repositorio})
      : _repositorio = repositorio ?? SolicitudRepositorio();

  // ---------------------------------------------------------------------------
  // Cargar solicitudes
  // ---------------------------------------------------------------------------

  /// Carga la lista de solicitudes pendientes desde el repositorio.
  Future<void> cargarSolicitudes() async {
    _estado = EstadoBandeja.cargando;
    _mensajeError = '';
    notifyListeners();

    try {
      AppLogger.accionUsuario('Carga de bandeja iniciada');
      _todasLasSolicitudes = await _repositorio.obtenerPendientes();
      _aplicarFiltros();

      _estado = _solicitudesFiltradas.isEmpty
          ? EstadoBandeja.vacio
          : EstadoBandeja.conDatos;

      AppLogger.info(
        'BandejaViewModel',
        'Solicitudes cargadas: ${_todasLasSolicitudes.length}',
      );
    } on NetworkException catch (e) {
      _mensajeError = e.mensaje;
      _estado = EstadoBandeja.error;
      AppLogger.error('BandejaViewModel', 'Error de red al cargar bandeja', e);
    } on AuthException catch (e) {
      _mensajeError = e.mensaje;
      _estado = EstadoBandeja.error;
      AppLogger.warning('BandejaViewModel', 'Sesión expirada: ${e.mensaje}');
    } catch (e) {
      _mensajeError = 'Error al cargar solicitudes. Intenta de nuevo.';
      _estado = EstadoBandeja.error;
      AppLogger.error('BandejaViewModel', 'Error inesperado al cargar bandeja', e);
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Filtros
  // ---------------------------------------------------------------------------

  /// Actualiza el texto de búsqueda y reaplica filtros.
  void buscar(String texto) {
    _textoBusqueda = texto;
    _aplicarFiltros();
    AppLogger.accionUsuario('Búsqueda aplicada', contexto: {'texto': texto});
    notifyListeners();
  }

  /// Cambia el filtro de estado activo.
  void cambiarFiltro(int indice) {
    _filtroActivo = indice;
    _aplicarFiltros();
    AppLogger.accionUsuario('Filtro cambiado', contexto: {'indice': indice});
    notifyListeners();
  }

  /// Aplica búsqueda y filtro de estado sobre [_todasLasSolicitudes].
  void _aplicarFiltros() {
    var lista = List<SolicitudModel>.from(_todasLasSolicitudes);

    // Filtro por estado (pestaña)
    const estados = ['', 'pendiente', 'aprobada', 'rechazada'];
    final estadoFiltro = estados[_filtroActivo];
    if (estadoFiltro.isNotEmpty) {
      lista = lista.where((s) => s.estado == estadoFiltro).toList();
    }

    // Filtro por texto libre (nombre solicitante o visitante)
    if (_textoBusqueda.isNotEmpty) {
      final textoMin = _textoBusqueda.toLowerCase();
      lista = lista.where((s) {
        return s.nombreSolicitante.toLowerCase().contains(textoMin) ||
            s.motivoVisita.toLowerCase().contains(textoMin) ||
            s.visitantes.any((v) =>
                v.nombreCompleto.toLowerCase().contains(textoMin));
      }).toList();
    }

    _solicitudesFiltradas = lista;
  }

  // ---------------------------------------------------------------------------
  // Aprobar solicitud
  // ---------------------------------------------------------------------------

  /// Aprueba la solicitud con [idSolicitud] y la elimina de la lista.
  ///
  /// [onExito] se llama si la operación fue exitosa.
  /// [onError] recibe el mensaje de error si falla.
  Future<void> aprobar({
    required int idSolicitud,
    required VoidCallback onExito,
    required void Function(String mensaje) onError,
  }) async {
    _idProcesando = idSolicitud;
    _estado = EstadoBandeja.procesando;
    notifyListeners();

    try {
      AppLogger.accionUsuario('Aprobando solicitud', contexto: {'id': idSolicitud});
      await _repositorio.aprobar(idSolicitud);

      // Eliminar de la lista local
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
      AppLogger.warning('BandejaViewModel', 'Concurrencia al aprobar: ${e.mensaje}');
    } catch (e) {
      _estado = EstadoBandeja.conDatos;
      _idProcesando = null;
      notifyListeners();
      onError('No se pudo aprobar. Intenta de nuevo.');
      AppLogger.error('BandejaViewModel', 'Error al aprobar solicitud $idSolicitud', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Rechazar solicitud
  // ---------------------------------------------------------------------------

  /// Rechaza la solicitud con [idSolicitud] y la elimina de la lista.
  Future<void> rechazar({
    required int idSolicitud,
    required VoidCallback onExito,
    required void Function(String mensaje) onError,
  }) async {
    _idProcesando = idSolicitud;
    _estado = EstadoBandeja.procesando;
    notifyListeners();

    try {
      AppLogger.accionUsuario('Rechazando solicitud', contexto: {'id': idSolicitud});
      await _repositorio.rechazar(idSolicitud);

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
      onError('No se pudo rechazar. Intenta de nuevo.');
      AppLogger.error('BandejaViewModel', 'Error al rechazar solicitud $idSolicitud', e);
    }
  }

  /// Limpiar error para permitir reintento.
  void limpiarError() {
    _mensajeError = '';
    _estado = EstadoBandeja.inicial;
    notifyListeners();
  }
}

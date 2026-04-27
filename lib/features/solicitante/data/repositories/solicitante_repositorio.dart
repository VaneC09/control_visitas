// =============================================================================
// Archivo: solicitud_repositorio.dart
// Módulo: solicitante/data/repositories
// Descripción: Repositorio para gestión de solicitudes del solicitante.
// Autor: OMEGA Solutions
// Versión: 1.0
// Fecha: 2026-04-26
// =============================================================================

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/solicitud_model.dart';

/// Repositorio que gestiona las operaciones de solicitudes del solicitante.
class SolicitanteRepositorio {
  final FlutterSecureStorage _storage;
  late final Dio _dio;

  SolicitanteRepositorio()
      : _storage = const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:8000/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Solicitudes
  // ---------------------------------------------------------------------------

  /// Obtiene todas las solicitudes del solicitante autenticado.
  Future<List<SolicitudModel>> obtenerSolicitudes() async {
    try {
      final response = await _dio.get('/solicitudes/mias');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => SolicitudModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapearError(e);
    }
  }

  /// Obtiene el detalle de una solicitud por ID.
  Future<SolicitudModel> obtenerDetalle(int idSolicitud) async {
    try {
      final response = await _dio.get('/solicitudes/$idSolicitud');
      return SolicitudModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapearError(e);
    }
  }

  /// Crea una nueva solicitud de visita.
  Future<SolicitudModel> crearSolicitud(SolicitudModel solicitud) async {
    try {
      final response = await _dio.post(
        '/solicitudes',
        data: solicitud.toJson(),
      );
      return SolicitudModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapearError(e);
    }
  }

  /// Cancela una solicitud existente.
  Future<void> cancelarSolicitud(int idSolicitud) async {
    try {
      await _dio.patch('/solicitudes/$idSolicitud/cancelar');
    } on DioException catch (e) {
      throw _mapearError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Catálogos
  // ---------------------------------------------------------------------------

  /// Obtiene los motivos de visita disponibles.
  Future<List<CatalogoModel>> obtenerMotivos() async {
    try {
      final response = await _dio.get('/catalogos/motivos');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => CatalogoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapearError(e);
    }
  }

  /// Obtiene los lugares de encuentro disponibles.
  Future<List<CatalogoModel>> obtenerLugares() async {
    try {
      final response = await _dio.get('/catalogos/lugares');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => CatalogoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapearError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Manejo de errores
  // ---------------------------------------------------------------------------

  String _mapearError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Error de conexión. Verifique su red e intente nuevamente.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode == 401) return 'Sesión expirada. Inicie sesión nuevamente.';
        if (statusCode == 403) return 'No tiene permisos para realizar esta acción.';
        if (statusCode == 404) return 'Recurso no encontrado.';
        if (statusCode >= 500) return 'Error del servidor. Intente más tarde.';
        return 'No fue posible completar la operación.';
      case DioExceptionType.cancel:
        return 'Operación cancelada.';
      default:
        return 'Error inesperado. Intente nuevamente.';
    }
  }
}

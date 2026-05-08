// ==============================================================
// Archivo    : solicitud_repositorio.dart
// Módulo     : features/autorizador/data/repositories
// Descripción: Operaciones reales sobre solicitudes de visita.
//              Consume la API Laravel del backend OMEGA.
// ==============================================================

import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/solicitud_model.dart';

class SolicitudRepositorio {
  final _dio = DioClient.backend;

  /// Obtiene solicitudes pendientes del autorizador autenticado.
  Future<List<SolicitudModel>> obtenerPendientes() async {
    try {
      final resp = await _dio.get('/solicitudes/pendientes');
      final lista = resp.data as List<dynamic>;
      return lista
          .map((j) => SolicitudModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  /// Obtiene el detalle completo de una solicitud.
  Future<SolicitudModel> obtenerDetalle(int idSolicitud) async {
    try {
      final resp = await _dio.get('/solicitudes/$idSolicitud');
      return SolicitudModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  /// Aprueba una solicitud. Lanza ConcurrenciaException si ya fue procesada.
  Future<void> aprobar(int idSolicitud) async {
    try {
      await _dio.post('/solicitudes/$idSolicitud/aprobar');
      AppLogger.accionUsuario('Solicitud aprobada',
          contexto: {'id': idSolicitud});
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  /// Rechaza una solicitud.
  Future<void> rechazar(int idSolicitud, {String? motivo}) async {
    try {
      await _dio.post('/solicitudes/$idSolicitud/rechazar',
          data: motivo != null ? {'motivo': motivo} : null);
      AppLogger.accionUsuario('Solicitud rechazada',
          contexto: {'id': idSolicitud});
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }
}

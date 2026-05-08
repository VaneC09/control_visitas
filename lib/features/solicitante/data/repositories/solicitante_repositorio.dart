// =============================================================================
// Archivo: solicitud_repositorio.dart
// Módulo: solicitante/data/repositories
// Descripción: Repositorio para gestión de solicitudes del solicitante.
// Autor: OMEGA Solutions
// Versión: 2.0
// Fecha: 2026-05-07
// =============================================================================

import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/solicitud_model.dart';

class SolicitanteRepositorio {
  final _dio     = DioClient.backend;
  final _session = SessionService.instancia;

  Future<List<SolicitudModel>> obtenerSolicitudes() async {
    try {
      final id = await _session.leerEmpleadoId();
      final resp = await _dio.get('/solicitudes/mias',
          queryParameters: {'idEmpleado': id});
      return (resp.data as List)
          .map((j) => SolicitudModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  Future<SolicitudModel> obtenerDetalle(int idSolicitud) async {
    try {
      final resp = await _dio.get('/solicitudes/$idSolicitud');
      return SolicitudModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  Future<SolicitudModel> crearSolicitud(SolicitudModel solicitud) async {
    try {
      final id = await _session.leerEmpleadoId();
      final body = solicitud.toJson();
      body['idSolicitante'] = id;
      final resp = await _dio.post('/solicitudes', data: body);
      AppLogger.accionUsuario('Solicitud creada');
      return SolicitudModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  Future<void> cancelarSolicitud(int idSolicitud) async {
    try {
      await _dio.patch('/solicitudes/$idSolicitud/cancelar');
      AppLogger.accionUsuario('Solicitud cancelada',
          contexto: {'id': idSolicitud});
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  Future<List<CatalogoModel>> obtenerMotivos() async {
    try {
      final resp = await _dio.get('/catalogos/motivos');
      return (resp.data as List)
          .map((j) => CatalogoModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  Future<List<CatalogoModel>> obtenerLugares() async {
    try {
      final resp = await _dio.get('/catalogos/lugares');
      return (resp.data as List)
          .map((j) => CatalogoModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }
}


// =============================================================================
// Archivo    : vigilante_repositorio.dart
// Módulo     : features/vigilante/data/repositories
// Descripción: Repositorio central del módulo vigilante. Consume todos los
//              endpoints REST del backend Java relacionados con vigilancia.
//              MODO DEMO: las llamadas HTTP están comentadas; se retornan
//              datos de prueba para permitir navegación sin backend.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 2.0.0
// Fecha      : 2026-05-07
// =============================================================================

import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/resultado_escaneo_model.dart';
import '../models/vigilante_model.dart';
import '../models/visita_hoy_model.dart';

class VigilanteRepositorio {
  final _dio     = DioClient.sam;
  final _backend = DioClient.backend;
  final _session = SessionService.instancia;

  /// Login del vigilante en el SAM.
  /// El SAM valida usuario, contraseña y que el teléfono esté registrado.
  Future<VigilanteModel> login(
    String usuario, String contrasena, String telefono) async {
    try {
      final resp = await _dio.post('/auth/login', data: {
        'usuario':           usuario.trim(),
        'password':          contrasena,
        'telefonoDispositivo': telefono.trim(),
        'rol':               'vigilante',
      });

      final data     = resp.data as Map<String, dynamic>;
      final token    = data['token']     as String;
      final empJson  = data['empleado']  as Map<String, dynamic>;
      final vigilante = VigilanteModel.fromJson(empJson);

      await _session.guardar(
        token:      token,
        idEmpleado: vigilante.idVigilante,
        rol:        'vigilante',
        nombre:     vigilante.nombreCompleto,
      );
      return vigilante;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException(
          'Credenciales incorrectas o dispositivo no registrado en el sistema.',
        );
      }
      throw DioClient.mapearError(e);
    }
  }

  /// Envía el código QR para validar acceso.
  Future<ResultadoEscaneoModel> escanear(String codigoQr) async {
    try {
      final idVigilante = await _session.leerEmpleadoId();
      final resp = await _backend.post('/qr/scan', data: {
        'codigoQr':    codigoQr,
        'idVigilante': idVigilante,
      });
      AppLogger.accionUsuario('QR escaneado',
          contexto: {'codigo': codigoQr});
      return ResultadoEscaneoModel.fromJson(
          resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  /// Registra la entrada de un visitante.
  Future<void> registrarEntrada(int idQr) async {
    try {
      final idVigilante = await _session.leerEmpleadoId();
      await _backend.post('/registros/entrada', data: {
        'idQr':        idQr,
        'idVigilante': idVigilante,
      });
      AppLogger.accionUsuario('Entrada registrada',
          contexto: {'idQr': idQr});
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  /// Registra la salida de un visitante.
  Future<void> registrarSalida(int idQr) async {
    try {
      final idVigilante = await _session.leerEmpleadoId();
      await _backend.post('/registros/salida', data: {
        'idQr':        idQr,
        'idVigilante': idVigilante,
      });
      AppLogger.accionUsuario('Salida registrada',
          contexto: {'idQr': idQr});
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  /// Solicita prórroga para QR vencido.
  Future<int> solicitarProrroga(int idQr) async {
    try {
      final resp = await _backend.post('/qr/$idQr/prorroga');
      return resp.data['idProrroga'] as int;
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  /// Consulta estado de una prórroga (usado en polling).
  Future<String> consultarEstadoProrroga(int idProrroga) async {
    try {
      final resp = await _backend.get('/qr/prorroga/$idProrroga/estado');
      return resp.data['estado'] as String;
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  /// Registra visita espontánea y genera QR temporal.
  Future<Map<String, dynamic>> registrarVisitaEspontanea({
    required String nombre,
    required String correo,
    required int    idDepartamento,
  }) async {
    try {
      final idVigilante = await _session.leerEmpleadoId();
      final resp = await _backend.post('/visitas/espontanea', data: {
        'nombre':         nombre.isEmpty ? 'Visitante' : nombre,
        'correo':         correo,
        'idDepartamento': idDepartamento,
        'idVigilante':    idVigilante,
      });
      AppLogger.accionUsuario('Visita espontánea registrada',
          contexto: {'correo': correo});
      return resp.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  /// Obtiene visitas aprobadas para hoy.
  Future<List<VisitaHoyModel>> obtenerVisitasHoy() async {
    try {
      final resp = await _backend.get('/visitas/hoy');
      return (resp.data as List)
          .map((j) => VisitaHoyModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioClient.mapearError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {} finally {
      await _session.cerrarSesion();
    }
  }
}


// =============================================================================
// Archivo    : vigilante_repositorio.dart
// Módulo     : features/vigilante/data/repositories
// Descripción: Repositorio central del módulo vigilante. Consume todos los
//              endpoints REST del backend Java relacionados con vigilancia.
//              MODO DEMO: las llamadas HTTP están comentadas; se retornan
//              datos de prueba para permitir navegación sin backend.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-27
// =============================================================================

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/resultado_escaneo_model.dart';
import '../models/vigilante_model.dart';
import '../models/visita_hoy_model.dart';

/// Repositorio del módulo vigilante.
class VigilanteRepositorio {
  static const String _baseUrl    = 'http://192.168.1.100:8080/ca-backend/api';
  static const String _claveToken = 'ca_access_token';
  static const String _claveVig   = 'ca_vigilante_id';

  final FlutterSecureStorage _almacenamiento;
  late final Dio _dio;

  VigilanteRepositorio({FlutterSecureStorage? almacenamiento})
      : _almacenamiento = almacenamiento ?? const FlutterSecureStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _almacenamiento.read(key: _claveToken);
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        AppLogger.http(options.method, options.path, null);
        return handler.next(options);
      },
    ));
  }

  // ---------------------------------------------------------------------------
  // Login del vigilante
  // ---------------------------------------------------------------------------

  /// Autentica al vigilante validando correo, contraseña y número de teléfono.
  Future<VigilanteModel> login(
      String correo, String contrasena, String telefonoDispositivo) async {
    // =========================================================================
    // MODO DEMO — descomentar con backend real
    // =========================================================================
    // try {
    //   final resp = await _dio.post('/auth/vigilante/login', data: {
    //     'correo': correo, 'contrasena': contrasena,
    //     'telefonoDispositivo': telefonoDispositivo,
    //   });
    //   final vigilante = VigilanteModel.fromJson(resp.data['vigilante']);
    //   await _almacenamiento.write(key: _claveToken, value: resp.data['accessToken']);
    //   await _almacenamiento.write(key: _claveVig, value: vigilante.idVigilante.toString());
    //   return vigilante;
    // } on DioException catch (e) {
    //   if (e.response?.statusCode == 401) throw const AuthException('Credenciales inválidas o dispositivo no registrado.');
    //   throw NetworkException('Sin conexión.', causa: e);
    // }
    // =========================================================================

    AppLogger.info('VigilanteRepositorio', 'Login demo — correo: $correo');
    await Future.delayed(const Duration(milliseconds: 700));
    if (correo.isEmpty || contrasena.isEmpty) {
      throw const AuthException('Ingresa usuario y contraseña.');
    }
    await _almacenamiento.write(key: _claveToken, value: 'demo_vigilante_token');
    await _almacenamiento.write(key: _claveVig, value: '1');
    return VigilanteModel(
      idVigilante: 1, nombre: 'Joaquín', apellidoPaterno: 'Mora',
      apellidoMaterno: 'Vega', numeroTelefono: telefonoDispositivo,
      correo: correo,
    );
  }

  // ---------------------------------------------------------------------------
  // Escanear QR
  // ---------------------------------------------------------------------------

  /// Envía el código QR al backend para validación y registro de entrada/salida.
  Future<ResultadoEscaneoModel> escanear(String codigoQr) async {
    // =========================================================================
    // MODO DEMO
    // =========================================================================
    // try {
    //   final resp = await _dio.post('/qr/scan', data: {'codigoQr': codigoQr});
    //   return ResultadoEscaneoModel.fromJson(resp.data as Map<String,dynamic>);
    // } on DioException catch (e) { throw _mapearError(e); }
    // =========================================================================

    AppLogger.info('VigilanteRepositorio', 'Escaneo demo — código: $codigoQr');
    await Future.delayed(const Duration(milliseconds: 600));

    // Demo: simular resultado válido de entrada
    return ResultadoEscaneoModel(
      estado:           EstadoEscaneo.validoEntrada,
      mensaje:          'Código válido.',
      horaActual:       DateTime.now().toIso8601String().substring(0, 19),
      permiteProrroga:  false,
      idQr:             1,
      codigoQr:         codigoQr,
      nombreVisitante:  'Juan Pérez García',
      correoVisitante:  'juan.perez@email.com',
      nombreAnfitrion:  'Ing. Roberto Sánchez',
      departamento:     'Sistemas',
      fechaVisita:      '26 mar 2026',
      horaVisita:       '10:00',
      toleranciaAntes:  15,
      toleranciaDespues:15,
      idRegistro:       null,
      horaEntradaRegistrada: '',
    );
  }

  // ---------------------------------------------------------------------------
  // Solicitar prórroga
  // ---------------------------------------------------------------------------

  /// Crea una solicitud de prórroga para un QR vencido. Retorna el idProrroga.
  Future<int> solicitarProrroga(int idQr) async {
    // =========================================================================
    // MODO DEMO
    // =========================================================================
    // try {
    //   final resp = await _dio.post('/qr/$idQr/prorroga');
    //   return resp.data['idProrroga'] as int;
    // } on DioException catch (e) { throw _mapearError(e); }
    // =========================================================================

    AppLogger.info('VigilanteRepositorio', 'Prórroga demo solicitada para QR: $idQr');
    await Future.delayed(const Duration(milliseconds: 500));
    return 1001; // ID demo
  }

  /// Consulta el estado de una prórroga (polling cada ~5s).
  Future<String> consultarEstadoProrroga(int idProrroga) async {
    // =========================================================================
    // MODO DEMO
    // =========================================================================
    // try {
    //   final resp = await _dio.get('/qr/prorroga/$idProrroga/estado');
    //   return resp.data['estado'] as String;
    // } on DioException catch (e) { throw _mapearError(e); }
    // =========================================================================

    await Future.delayed(const Duration(seconds: 3));
    return 'pendiente'; // Demo siempre pendiente hasta timeout
  }

  // ---------------------------------------------------------------------------
  // Visita espontánea
  // ---------------------------------------------------------------------------

  /// Registra un visitante walk-in y genera QR temporal.
  Future<Map<String, dynamic>> registrarVisitaEspontanea({
    required String nombre,
    required String correo,
    required int    idDepartamento,
  }) async {
    // =========================================================================
    // MODO DEMO
    // =========================================================================
    // try {
    //   final resp = await _dio.post('/visitas/espontanea', data: {
    //     'nombre': nombre, 'correo': correo, 'idDepartamento': idDepartamento,
    //   });
    //   return resp.data as Map<String, dynamic>;
    // } on DioException catch (e) { throw _mapearError(e); }
    // =========================================================================

    AppLogger.info('VigilanteRepositorio', 'Visita espontánea demo — correo: $correo');
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'idQr':    9001,
      'codigoQr':'WI-000001-0001-9999',
      'mensaje': 'QR temporal generado. Se enviará al correo del visitante.',
    };
  }

  // ---------------------------------------------------------------------------
  // Visitas del día
  // ---------------------------------------------------------------------------

  /// Retorna la lista de visitas aprobadas para hoy.
  Future<List<VisitaHoyModel>> obtenerVisitasHoy() async {
    // =========================================================================
    // MODO DEMO
    // =========================================================================
    // try {
    //   final resp = await _dio.get('/visitas/hoy');
    //   return (resp.data as List).map((j) => VisitaHoyModel.fromJson(j)).toList();
    // } on DioException catch (e) { throw _mapearError(e); }
    // =========================================================================

    AppLogger.info('VigilanteRepositorio', 'Visitas hoy — demo');
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      VisitaHoyModel(
        idSolicitud: 1, fechaInicio: '2026-04-27T10:00:00',
        estadoSolicitud: 'aprobada', tipoSolicitud: 'agendada',
        lugarEncuentro: 'Edificio A', nombreAnfitrion: 'Ing. Roberto Sánchez',
        departamento: 'Sistemas', idQr: 1, codigoQr: 'VIS-2026-001234',
        estadoQr: 'pendiente', nombreVisitante: 'Juan Pérez García',
      ),
      VisitaHoyModel(
        idSolicitud: 2, fechaInicio: '2026-04-27T14:00:00',
        estadoSolicitud: 'aprobada', tipoSolicitud: 'agendada',
        lugarEncuentro: 'Edificio C', nombreAnfitrion: 'Lic. Ana Torres',
        departamento: 'Recursos Humanos', idQr: 2, codigoQr: 'VIS-2026-001235',
        estadoQr: 'pendiente', nombreVisitante: 'María López Sánchez',
      ),
      VisitaHoyModel(
        idSolicitud: 3, fechaInicio: '2026-04-27T09:00:00',
        estadoSolicitud: 'aprobada', tipoSolicitud: 'espontanea',
        lugarEncuentro: 'Edificio B', nombreAnfitrion: 'Dr. Carlos Méndez',
        departamento: 'Dirección', idQr: 3, codigoQr: 'WI-000003-0003-1234',
        estadoQr: 'en_camino', nombreVisitante: 'Luis Ramírez Ortiz',
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Cerrar sesión
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    await _almacenamiento.delete(key: _claveToken);
    await _almacenamiento.delete(key: _claveVig);
    AppLogger.info('VigilanteRepositorio', 'Sesión vigilante cerrada');
  }

  // ---------------------------------------------------------------------------
  // Mapeo de errores
  // ---------------------------------------------------------------------------

  Exception _mapearError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException('Sin conexión al servidor.', causa: e);
    }
    if (e.response?.statusCode == 401) {
      return const AuthException('Sesión expirada. Inicia sesión nuevamente.');
    }
    return ServerException('Error del servidor.', codigoHttp: e.response?.statusCode);
  }
}

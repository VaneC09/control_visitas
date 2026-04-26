// =============================================================================
// Archivo    : solicitud_repositorio.dart
// Módulo     : features/autorizador/data/repositories
// Descripción: Repositorio de solicitudes. Centraliza todas las llamadas HTTP
//              relacionadas con solicitudes de visita hacia el backend Java.
//              Implementa el patrón Repository separando la fuente de datos
//              de la lógica de presentación .
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/solicitud_model.dart';
import '../models/visitante_model.dart';

/// Repositorio que abstrae el acceso a datos de solicitudes de visita.
/// Consume la API REST del backend Java desplegado en GlassFish.
///
/// NOTA: Mientras el backend no esté disponible, los métodos están
/// comentados y se retornan datos de prueba para permitir navegación.
class SolicitudRepositorio {
  // ---------------------------------------------------------------------------
  // Constantes de configuración
  // ---------------------------------------------------------------------------

  /// URL base del backend Java en GlassFish.
  /// Cambiar a la IP/dominio real del servidor en producción.
  static const String _baseUrl = 'http://192.168.1.100:8080/ca-backend/api';

  // Clave de almacenamiento seguro para el token JWT
  static const String _claveToken = 'ca_access_token';

  // ---------------------------------------------------------------------------
  // Dependencias
  // ---------------------------------------------------------------------------

  final FlutterSecureStorage _almacenamiento;

  // Instancia de Dio con interceptor de logs
  late final Dio _dio;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  SolicitudRepositorio({FlutterSecureStorage? almacenamiento})
      : _almacenamiento = almacenamiento ?? const FlutterSecureStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    // Interceptor para adjuntar JWT automáticamente en cada petición
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _almacenamiento.read(key: _claveToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        AppLogger.http(options.method, options.path, null);
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.http(
          response.requestOptions.method,
          response.requestOptions.path,
          response.statusCode,
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.error(
          'SolicitudRepositorio',
          'Error HTTP: ${error.message}',
          error,
        );
        return handler.next(error);
      },
    ));
  }

  // ---------------------------------------------------------------------------
  // Método: obtener solicitudes pendientes
  // ---------------------------------------------------------------------------

  /// Obtiene la lista de solicitudes pendientes del autorizador autenticado.
  ///
  /// Retorna lista vacía si no hay solicitudes pendientes.
  /// Lanza [NetworkException] ante fallo de conectividad.
  /// Lanza [AuthException] si el token expiró (401).
  /// Lanza [ServerException] ante error interno del servidor (5xx).
  Future<List<SolicitudModel>> obtenerPendientes() async {
    // =========================================================================
    // MODO DEMO — descomentar cuando el backend esté disponible
    // =========================================================================
    // try {
    //   final respuesta = await _dio.get('/solicitudes/pendientes');
    //   final lista = respuesta.data as List<dynamic>;
    //   return lista
    //       .map((json) => SolicitudModel.fromJson(json as Map<String, dynamic>))
    //       .toList();
    // } on DioException catch (e) {
    //   throw _mapearError(e);
    // }
    // =========================================================================

    // Datos de prueba para modo demo offline
    AppLogger.info('SolicitudRepositorio', 'Modo demo — retornando datos de prueba');
    await Future.delayed(const Duration(milliseconds: 800));
    return _datosDemoPendientes();
  }

  // ---------------------------------------------------------------------------
  // Método: obtener detalle de solicitud
  // ---------------------------------------------------------------------------

  /// Obtiene el detalle completo de una solicitud por su ID.
  ///
  /// Lanza [NetworkException], [AuthException] o [ServerException] según el caso.
  Future<SolicitudModel> obtenerDetalle(int idSolicitud) async {
    // =========================================================================
    // MODO DEMO
    // =========================================================================
    // try {
    //   final respuesta = await _dio.get('/solicitudes/$idSolicitud');
    //   return SolicitudModel.fromJson(respuesta.data as Map<String, dynamic>);
    // } on DioException catch (e) {
    //   throw _mapearError(e);
    // }
    // =========================================================================

    await Future.delayed(const Duration(milliseconds: 500));
    return _datosDemoPendientes()
        .firstWhere((s) => s.idSolicitud == idSolicitud,
            orElse: () => _datosDemoPendientes().first);
  }

  // ---------------------------------------------------------------------------
  // Método: aprobar solicitud
  // ---------------------------------------------------------------------------

  /// Envía la acción de aprobación al backend.
  ///
  /// Retorna [true] si se aprobó correctamente.
  /// Lanza [ConcurrenciaException] si ya fue procesada (409).
  Future<bool> aprobar(int idSolicitud) async {
    // =========================================================================
    // MODO DEMO
    // =========================================================================
    // try {
    //   await _dio.post('/solicitudes/$idSolicitud/aprobar');
    //   AppLogger.accionUsuario('Solicitud aprobada', contexto: {'id': idSolicitud});
    //   return true;
    // } on DioException catch (e) {
    //   if (e.response?.statusCode == 409) {
    //     throw const ConcurrenciaException(
    //       'Esta solicitud ya fue procesada por otro autorizador.');
    //   }
    //   throw _mapearError(e);
    // }
    // =========================================================================

    AppLogger.accionUsuario('Solicitud APROBADA (demo)', contexto: {'id': idSolicitud});
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  // ---------------------------------------------------------------------------
  // Método: rechazar solicitud
  // ---------------------------------------------------------------------------

  /// Envía la acción de rechazo al backend.
  ///
  /// Retorna [true] si se rechazó correctamente.
  /// Lanza [ConcurrenciaException] si ya fue procesada (409).
  Future<bool> rechazar(int idSolicitud) async {
    // =========================================================================
    // MODO DEMO
    // =========================================================================
    // try {
    //   await _dio.post('/solicitudes/$idSolicitud/rechazar');
    //   AppLogger.accionUsuario('Solicitud rechazada', contexto: {'id': idSolicitud});
    //   return true;
    // } on DioException catch (e) {
    //   if (e.response?.statusCode == 409) {
    //     throw const ConcurrenciaException(
    //       'Esta solicitud ya fue procesada por otro autorizador.');
    //   }
    //   throw _mapearError(e);
    // }
    // =========================================================================

    AppLogger.accionUsuario('Solicitud RECHAZADA (demo)', contexto: {'id': idSolicitud});
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  // ---------------------------------------------------------------------------
  // Helper: mapeo de errores Dio → excepciones de dominio
  // ---------------------------------------------------------------------------

  /// Convierte un [DioException] en la excepción de dominio correspondiente.
  Exception _mapearError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          'Sin conexión al servidor. Verifica tu red.',
          causa: error,
        );
      case DioExceptionType.badResponse:
        final codigo = error.response?.statusCode ?? 0;
        if (codigo == 401 || codigo == 403) {
          return const AuthException('Sesión expirada. Inicia sesión nuevamente.');
        }
        return ServerException(
          'Error del servidor. Intenta más tarde.',
          codigoHttp: codigo,
        );
      default:
        return NetworkException('Error de red inesperado.', causa: error);
    }
  }

  // ---------------------------------------------------------------------------
  // Datos de demostración (solo para modo offline / pruebas)
  // ---------------------------------------------------------------------------

  /// Retorna solicitudes de prueba para visualización sin backend.
  List<SolicitudModel> _datosDemoPendientes() {
    return [
      SolicitudModel(
        idSolicitud: 1,
        fechaInicio: '2026-03-26T10:00:00',
        toleranciaAntes: 15,
        toleranciaDespues: 15,
        prorrogaToleran: false,
        observaciones: 'Reunión de proyecto para revisar avances del sistema de gestión '
            'de accesos. Se revisarán los módulos de autenticación, registro '
            'de visitas y generación de reportes.',
        fechaCreacion: '2026-03-25T09:30:00',
        estado: 'pendiente',
        tipoSolicitud: 'agendada',
        lugarEncuentro: 'Edificio A',
        motivoVisita: 'Reunión de proyecto',
        idSolicitante: 1,
        nombreSolicitante: 'Ing. Roberto Sánchez',
        departamentoSolicitante: 'Sistemas',
        correoSolicitante: 'roberto.sanchez@institucion.edu.mx',
        idAutorizador: 2,
        nombreAutorizador: 'Ana Torres',
        visitantes: [
          VisitanteModel(
            idVisitante: 1,
            nombre: 'Juan',
            apellidos: 'Pérez García',
            correoPersonal: 'juan.perez@email.com',
          ),
        ],
      ),
      SolicitudModel(
        idSolicitud: 2,
        fechaInicio: '2026-03-27T14:00:00',
        toleranciaAntes: 10,
        toleranciaDespues: 20,
        prorrogaToleran: false,
        observaciones: 'Entrevista laboral para el puesto de analista de sistemas.',
        fechaCreacion: '2026-03-25T11:00:00',
        estado: 'pendiente',
        tipoSolicitud: 'agendada',
        lugarEncuentro: 'Edificio C',
        motivoVisita: 'Entrevista laboral',
        idSolicitante: 2,
        nombreSolicitante: 'Lic. Ana Torres',
        departamentoSolicitante: 'Recursos Humanos',
        correoSolicitante: 'ana.torres@institucion.edu.mx',
        idAutorizador: 2,
        nombreAutorizador: 'Ana Torres',
        visitantes: [
          VisitanteModel(
            idVisitante: 2,
            nombre: 'María',
            apellidos: 'López Sánchez',
            correoPersonal: 'maria.lopez@email.com',
          ),
        ],
      ),
      SolicitudModel(
        idSolicitud: 3,
        fechaInicio: '2026-03-28T09:00:00',
        toleranciaAntes: 15,
        toleranciaDespues: 15,
        prorrogaToleran: true,
        observaciones: 'Consultoría externa de optimización de procesos administrativos.',
        fechaCreacion: '2026-03-25T14:20:00',
        estado: 'pendiente',
        tipoSolicitud: 'espontanea',
        lugarEncuentro: 'Edificio B',
        motivoVisita: 'Consultoría externa',
        idSolicitante: 3,
        nombreSolicitante: 'Dr. Carlos Méndez',
        departamentoSolicitante: 'Dirección',
        correoSolicitante: 'carlos.mendez@institucion.edu.mx',
        idAutorizador: 2,
        nombreAutorizador: 'Ana Torres',
        visitantes: [
          VisitanteModel(
            idVisitante: 3,
            nombre: 'Luis',
            apellidos: 'Ramírez Ortiz',
            correoPersonal: 'luis.ramirez@consultora.com',
          ),
          VisitanteModel(
            idVisitante: 4,
            nombre: 'Sofía',
            apellidos: 'Reyes Moreno',
            correoPersonal: 'sofia.reyes@consultora.com',
          ),
        ],
      ),
    ];
  }
}

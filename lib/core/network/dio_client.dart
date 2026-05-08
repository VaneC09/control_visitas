// ==============================================================
// Archivo    : dio_client.dart
// Módulo     : core/network
// Descripción: Cliente HTTP centralizado. Todos los repositorios
//              usan esta instancia para garantizar consistencia.
// ==============================================================

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../errors/exceptions.dart';
import '../utils/app_logger.dart';

class DioClient {
  DioClient._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Dio _build(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: AppConfig.timeoutConexion),
      receiveTimeout: Duration(seconds: AppConfig.timeoutRespuesta),
      headers: {'Content-Type': 'application/json'},
    ));

    // Interceptor: agrega JWT en cada petición
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'ca_access_token');
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
        AppLogger.error('DioClient', '${error.message}', error);
        return handler.next(error);
      },
    ));
    return dio;
  }

  /// Cliente para el backend principal (Laravel / GlassFish).
  static final Dio backend = _build(AppConfig.baseUrl);

  /// Cliente para el SAM externo.
  static final Dio sam = _build(AppConfig.samUrl);

  /// Convierte DioException en excepción de dominio.
  static Exception mapearError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Sin respuesta del servidor. Verifica tu conexión.',
          causa: e,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          'No se pudo conectar al servidor. Verifica tu red.',
          causa: e,
        );
      case DioExceptionType.badResponse:
        final codigo = e.response?.statusCode ?? 0;
        if (codigo == 401) {
          return const AuthException(
            'Tu sesión ha expirado. Inicia sesión nuevamente.',
          );
        }
        if (codigo == 403) {
          return const PermisosException(
            'No tienes permiso para realizar esta acción.',
          );
        }
        if (codigo == 422) {
          final errores = e.response?.data?['errores'] as Map<String,dynamic>?;
          return ValidationException(
            'Datos inválidos. Revisa la información ingresada.',
            erroresCampo: errores?.map(
              (k, v) => MapEntry(k, v.toString()),
            ),
          );
        }
        if (codigo == 409) {
          return const ConcurrenciaException(
            'Esta operación ya fue realizada por otro usuario.',
          );
        }
        if (codigo >= 500) {
          return ServerException(
            'Error interno del servidor. Intenta más tarde.',
            codigoHttp: codigo,
          );
        }
        return ServerException(
          'No se pudo completar la operación.',
          codigoHttp: codigo,
        );
      default:
        return NetworkException('Error de red inesperado.', causa: e);
    }
  }
}

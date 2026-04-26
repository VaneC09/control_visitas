// =============================================================================
// Archivo    : app_routes.dart
// Módulo     : core/config
// Descripción: Rutas nombradas de la aplicación. Centraliza la navegación
//              para facilitar mantenimiento y auditoría de flujo.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:flutter/material.dart';
import '../../features/autorizador/presentation/views/seleccion_rol_view.dart';
import '../../features/autorizador/presentation/views/login_view.dart';
import '../../features/autorizador/presentation/views/bandeja_view.dart';
import '../../features/autorizador/presentation/views/detalle_solicitud_view.dart';
import '../../features/autorizador/presentation/views/notificaciones_view.dart';

/// Nombres de rutas de la aplicación.
class AppRoutes {
  AppRoutes._();

  static const String seleccionRol   = '/';
  static const String login          = '/login';
  static const String bandeja        = '/bandeja';
  static const String detalleSolicitud = '/bandeja/detalle';
  static const String notificaciones = '/notificaciones';
}

/// Mapa de rutas registradas en MaterialApp.
Map<String, WidgetBuilder> get rutasApp => {
  AppRoutes.seleccionRol:    (_) => const SeleccionRolView(),
  AppRoutes.login:           (_) => const LoginView(),
  AppRoutes.bandeja:         (_) => const BandejaView(),
  AppRoutes.detalleSolicitud:(_) => const DetalleSolicitudView(),
  AppRoutes.notificaciones:  (_) => const NotificacionesView(),
};
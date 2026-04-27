// =============================================================================
// Archivo    : app_routes.dart
// Módulo     : core/config
// Descripción: Rutas nombradas de la aplicación.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.1.0
// Fecha      : 2026-04-26
// =============================================================================

import 'package:flutter/material.dart';
import '../../features/shared/presentation/views/seleccion_rol_view.dart';
import '../../features/autorizador/presentation/views/login_view.dart';
import '../../features/autorizador/presentation/views/bandeja_view.dart';
import '../../features/autorizador/presentation/views/detalle_solicitud_view.dart';
import '../../features/autorizador/presentation/views/notificaciones_view.dart';
import '../../features/solicitante/presentation/views/dashboard_solicitante_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String seleccionRol         = '/';
  static const String login                = '/login';
  static const String bandeja              = '/bandeja';
  static const String detalleSolicitud     = '/bandeja/detalle';
  static const String notificaciones       = '/notificaciones';
  static const String dashboardSolicitante = '/solicitante/dashboard';
}

Map<String, WidgetBuilder> get rutasApp => {
  AppRoutes.seleccionRol:         (_) => const SeleccionRolView(),
  AppRoutes.login:                (_) => const LoginView(),
  AppRoutes.bandeja:              (_) => const BandejaView(),
  AppRoutes.detalleSolicitud:     (_) => const DetalleSolicitudView(),
  AppRoutes.notificaciones:       (_) => const NotificacionesView(),
  AppRoutes.dashboardSolicitante: (_) => const DashboardSolicitanteView(),
};
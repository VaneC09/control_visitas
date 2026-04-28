// =============================================================================
// Archivo    : app_routes.dart
// Módulo     : core/config
// Descripción: Rutas nombradas de la aplicación. Centraliza la navegación
//              de los tres módulos: autorizador, solicitante y vigilante.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.2.0
// Fecha      : 2026-04-27
// Cambios    : v1.1.0 — Solicitante habilitado
//              v1.2.0 — Se agregan rutas del módulo vigilante
// =============================================================================

import 'package:flutter/material.dart';

// Shared
import '../../features/shared/presentation/views/seleccion_rol_view.dart';

// Autorizador
import '../../features/autorizador/presentation/views/login_view.dart';
import '../../features/autorizador/presentation/views/bandeja_view.dart';
import '../../features/autorizador/presentation/views/detalle_solicitud_view.dart';
import '../../features/autorizador/presentation/views/notificaciones_view.dart';

// Solicitante
import '../../features/solicitante/presentation/views/dashboard_solicitante_view.dart';

// Vigilante
import '../../features/vigilante/presentation/views/login_vigilante_view.dart';
import '../../features/vigilante/presentation/views/home_vigilante_view.dart';
import '../../features/vigilante/presentation/views/escaner_qr_view.dart';
import '../../features/vigilante/presentation/views/resultado_escaneo_view.dart';
import '../../features/vigilante/presentation/views/espera_prorroga_view.dart';
import '../../features/vigilante/presentation/views/visita_espontanea_view.dart';
import '../../features/vigilante/presentation/views/proximas_visitas_view.dart';

/// Constantes de rutas nombradas de la aplicación.
class AppRoutes {
  AppRoutes._();

  // ── Shared ─────────────────────────────────────────────────────────────────
  static const String seleccionRol = '/';

  // ── Autorizador ────────────────────────────────────────────────────────────
  // IMPORTANTE: se renombra de '/login' a '/autorizador/login' para que no
  // colisione con el login del vigilante y el flujo de selección de rol funcione.
  static const String loginAutorizador  = '/autorizador/login';
  static const String bandeja           = '/autorizador/bandeja';
  static const String detalleSolicitud  = '/autorizador/bandeja/detalle';
  static const String notificaciones    = '/autorizador/notificaciones';

  // ── Solicitante ────────────────────────────────────────────────────────────
  static const String dashboardSolicitante = '/solicitante/dashboard';

  // ── Vigilante ──────────────────────────────────────────────────────────────
  static const String loginVigilante   = '/vigilante/login';
  static const String homeVigilante    = '/vigilante/home';
  static const String escanerQr        = '/vigilante/escaner';
  static const String resultadoEscaneo = '/vigilante/resultado';
  static const String esperaProrroga   = '/vigilante/prorroga';
  static const String visitaEspontanea = '/vigilante/espontanea';
  static const String proximasVisitas  = '/vigilante/visitas';
}

/// Mapa de rutas registradas en MaterialApp.
Map<String, WidgetBuilder> get rutasApp => {
  // Shared
  AppRoutes.seleccionRol:         (_) => const SeleccionRolView(),

  // Autorizador
  AppRoutes.loginAutorizador:     (_) => const LoginView(),
  AppRoutes.bandeja:              (_) => const BandejaView(),
  AppRoutes.detalleSolicitud:     (_) => const DetalleSolicitudView(),
  AppRoutes.notificaciones:       (_) => const NotificacionesView(),

  // Solicitante
  AppRoutes.dashboardSolicitante: (_) => const DashboardSolicitanteView(),

  // Vigilante
  AppRoutes.loginVigilante:       (_) => const LoginVigilanteView(),
  AppRoutes.homeVigilante:        (_) => const HomeVigilanteView(),
  AppRoutes.escanerQr:            (_) => const EscanerQrView(),
  AppRoutes.resultadoEscaneo:     (_) => const ResultadoEscaneoView(),
  AppRoutes.esperaProrroga:       (_) => const EsperaProrrorgaView(),
  AppRoutes.visitaEspontanea:     (_) => const VisitaEspontaneaView(),
  AppRoutes.proximasVisitas:      (_) => const ProximasVisitasView(),
};

// =============================================================================
// Archivo    : notificaciones_view.dart
// Módulo     : features/autorizador/presentation/views
// Descripción: Pantalla 6 — Notificaciones internas del autorizador.
//              Muestra historial de eventos del sistema con acceso directo
//              al detalle de cada solicitud.
// Autor      : Yadhira Anadanely Benitez millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/solicitud_model.dart';
import '../../data/repositories/solicitud_repositorio.dart';

/// Modelo simple de notificación interna.
class _NotificacionInterna {
  final int    id;
  final String titulo;
  final String descripcion;
  final String tiempo;
  final bool   leida;
  final int?   idSolicitud;
  final IconData icono;
  final Color    colorIcono;
  final Color    colorFondoIcono;

  const _NotificacionInterna({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tiempo,
    required this.leida,
    this.idSolicitud,
    required this.icono,
    required this.colorIcono,
    required this.colorFondoIcono,
  });
}

/// Pantalla de notificaciones internas del autorizador.
class NotificacionesView extends StatefulWidget {
  const NotificacionesView({super.key});

  @override
  State<NotificacionesView> createState() => _NotificacionesViewState();
}

class _NotificacionesViewState extends State<NotificacionesView> {
  // Notificaciones de demostración
  final List<_NotificacionInterna> _notificaciones = [
    _NotificacionInterna(
      id: 1,
      titulo: 'Nueva solicitud pendiente',
      descripcion: 'Ing. Roberto Sánchez solicita visita de Juan Pérez García · '
          'Reunión de proyecto · 26 mar 10:00',
      tiempo: 'Hace 3 minutos',
      leida: false,
      idSolicitud: 1,
      icono: Icons.notifications_active_rounded,
      colorIcono: AppColors.coralPrimario,
      colorFondoIcono: AppColors.sutilCalido,
    ),
    _NotificacionInterna(
      id: 2,
      titulo: 'Nueva solicitud pendiente',
      descripcion: 'Lic. Ana Torres solicita visita de María López Sánchez · '
          'Entrevista laboral · 27 mar 14:00',
      tiempo: 'Hace 24 minutos',
      leida: false,
      idSolicitud: 2,
      icono: Icons.notifications_active_rounded,
      colorIcono: AppColors.coralPrimario,
      colorFondoIcono: AppColors.sutilCalido,
    ),
    _NotificacionInterna(
      id: 3,
      titulo: 'Solicitud aprobada',
      descripcion: 'Aprobaste la solicitud de Carlos Méndez Ruiz · SOL-2026-00310',
      tiempo: 'Ayer, 16:35',
      leida: true,
      icono: Icons.check_circle_rounded,
      colorIcono: AppColors.exitoVerde,
      colorFondoIcono: const Color(0xFFD1FAE5),
    ),
    _NotificacionInterna(
      id: 4,
      titulo: 'Solicitud rechazada',
      descripcion: 'Rechazaste la solicitud de Sofía Reyes García · SOL-2026-00298',
      tiempo: 'Ayer, 11:12',
      leida: true,
      icono: Icons.cancel_rounded,
      colorIcono: AppColors.coralAccion,
      colorFondoIcono: const Color(0xFFFEE2E2),
    ),
    _NotificacionInterna(
      id: 5,
      titulo: 'Solicitud expirada',
      descripcion: 'La solicitud SOL-2026-00285 expiró sin ser procesada.',
      tiempo: 'Hace 2 días',
      leida: true,
      icono: Icons.timer_off_rounded,
      colorIcono: AppColors.azulCielo,
      colorFondoIcono: AppColors.azulNube,
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.navegacion('NotificacionesView');
  }

  // ---------------------------------------------------------------------------
  // Marcar como leída
  // ---------------------------------------------------------------------------

  void _marcarLeida(int id) {
    setState(() {
      final idx = _notificaciones.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        final n = _notificaciones[idx];
        _notificaciones[idx] = _NotificacionInterna(
          id:              n.id,
          titulo:          n.titulo,
          descripcion:     n.descripcion,
          tiempo:          n.tiempo,
          leida:           true,
          idSolicitud:     n.idSolicitud,
          icono:           n.icono,
          colorIcono:      n.colorIcono,
          colorFondoIcono: n.colorFondoIcono,
        );
      }
    });
    AppLogger.accionUsuario('Notificación marcada como leída', contexto: {'id': id});
  }

  // ---------------------------------------------------------------------------
  // Navegar al detalle de la solicitud
  // ---------------------------------------------------------------------------

  Future<void> _irADetalle(BuildContext context, int idSolicitud) async {
    AppLogger.accionUsuario(
        'Acceso a detalle desde notificación', contexto: {'id': idSolicitud});

    // Obtener la solicitud del repositorio (demo)
    final repo = SolicitudRepositorio();
    final solicitud = await repo.obtenerDetalle(idSolicitud);

    if (!context.mounted) return;

    Navigator.pushNamed(
      context,
      AppRoutes.detalleSolicitud,
      arguments: solicitud,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final noLeidas = _notificaciones.where((n) => !n.leida).length;

    return Scaffold(
      backgroundColor: AppColors.superficie0,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notificaciones'),
            Text(
              'Autorizador · $noLeidas nueva(s)',
              style: tema.textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          if (noLeidas > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var i = 0; i < _notificaciones.length; i++) {
                    final n = _notificaciones[i];
                    _notificaciones[i] = _NotificacionInterna(
                      id: n.id, titulo: n.titulo, descripcion: n.descripcion,
                      tiempo: n.tiempo, leida: true, idSolicitud: n.idSolicitud,
                      icono: n.icono, colorIcono: n.colorIcono,
                      colorFondoIcono: n.colorFondoIcono,
                    );
                  }
                });
                AppLogger.accionUsuario('Todas las notificaciones marcadas como leídas');
              },
              child: const Text('Marcar todas'),
            ),
        ],
      ),
      body: _notificaciones.isEmpty
          ? _PantallaVaciaWidget()
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.sm),
              itemCount: _notificaciones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final notif = _notificaciones[i];
                return _TarjetaNotificacionWidget(
                  notificacion: notif,
                  onTap: () {
                    _marcarLeida(notif.id);
                    if (notif.idSolicitud != null) {
                      _irADetalle(ctx, notif.idSolicitud!);
                    }
                  },
                );
              },
            ),
    );
  }
}

// =============================================================================
// Tarjeta de notificación individual
// =============================================================================

class _TarjetaNotificacionWidget extends StatelessWidget {
  final _NotificacionInterna notificacion;
  final VoidCallback         onTap;

  const _TarjetaNotificacionWidget({
    required this.notificacion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: notificacion.leida ? AppColors.superficie0 : AppColors.azulNube,
          borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
          border: Border.all(
            color: notificacion.leida
                ? AppColors.superficie1
                : AppColors.azulCielo,
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono de la notificación
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notificacion.leida
                    ? AppColors.superficie1
                    : notificacion.colorFondoIcono,
                shape: BoxShape.circle,
              ),
              child: Icon(
                notificacion.icono,
                size: 20,
                color: notificacion.leida
                    ? AppColors.encabezadoOscuro
                    : notificacion.colorIcono,
              ),
            ),

            const SizedBox(width: AppSpacing.xs),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + punto indicador de no leído
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notificacion.titulo,
                          style: tema.textTheme.bodyMedium?.copyWith(
                            color: notificacion.leida
                                ? AppColors.encabezadoOscuro
                                : AppColors.navyProfundo,
                            fontWeight: notificacion.leida
                                ? FontWeight.w400
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notificacion.leida)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.coralPrimario,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Descripción
                  Text(
                    notificacion.descripcion,
                    style: tema.textTheme.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Tiempo
                  Text(
                    notificacion.tiempo,
                    style: tema.textTheme.labelMedium?.copyWith(
                        color: AppColors.azulCielo),
                  ),

                  // Botón "Ver solicitud" si tiene idSolicitud
                  if (notificacion.idSolicitud != null) ...[
                    const SizedBox(height: 6),
                    OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        side: BorderSide(
                            color: AppColors.encabezadoOscuro, width: 0.5),
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                      child: const Text('Ver solicitud ›'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Pantalla vacía de notificaciones
// =============================================================================

class _PantallaVaciaWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off_rounded,
              size: 52, color: AppColors.encabezadoOscuro),
          const SizedBox(height: AppSpacing.sm),
          Text('Sin notificaciones', style: tema.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Recibirás alertas cuando haya solicitudes pendientes.',
            style: tema.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

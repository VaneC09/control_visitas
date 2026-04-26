// =============================================================================
// Archivo    : detalle_solicitud_view.dart
// Módulo     : features/autorizador/presentation/views
// Descripción: Pantalla 3 — Detalle completo de una solicitud de visita.
//              Información organizada por secciones con botones fijos en
//              la parte inferior para Autorizar y Rechazar.
// Autor      : Yadhira Anadanely Benitez millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../bloc/bandeja_viewmodel.dart';
import '../../data/models/solicitud_model.dart';
import '../widgets/dialogo_confirmacion_widget.dart';

/// Pantalla de detalle de solicitud de visita.
/// Recibe la [SolicitudModel] como argumento de navegación.
class DetalleSolicitudView extends StatelessWidget {
  const DetalleSolicitudView({super.key});

  // ---------------------------------------------------------------------------
  // Helper: formatear fecha ISO
  // ---------------------------------------------------------------------------

  String _formatearFecha(String fechaIso) {
    try {
      final fecha = DateTime.parse(fechaIso);
      return DateFormat("d 'de' MMMM 'de' yyyy", 'es_MX').format(fecha);
    } catch (_) {
      return fechaIso;
    }
  }

  String _formatearHora(String fechaIso) {
    try {
      final fecha = DateTime.parse(fechaIso);
      return DateFormat('HH:mm').format(fecha);
    } catch (_) {
      return '';
    }
  }

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  Future<void> _confirmarAccion(
    BuildContext context,
    SolicitudModel solicitud,
    TipoAccionDialogo tipo,
  ) async {
    AppLogger.accionUsuario(
      'Diálogo de ${tipo == TipoAccionDialogo.aprobar ? "aprobación" : "rechazo"} abierto',
      contexto: {'id': solicitud.idSolicitud},
    );

    final confirmo = await DialogoConfirmacionWidget.mostrar(
      context: context,
      tipo: tipo,
      nombreSolicitante: solicitud.nombreSolicitante,
    );

    if (confirmo != true || !context.mounted) return;

    final vm = context.read<BandejaViewModel>();

    if (tipo == TipoAccionDialogo.aprobar) {
      await vm.aprobar(
        idSolicitud: solicitud.idSolicitud,
        onExito: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✓ Solicitud aprobada correctamente'),
            backgroundColor: AppColors.exitoVerde,
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.pop(context);  // Regresar a la bandeja
        },
        onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.coralAccion,
          behavior: SnackBarBehavior.floating,
        )),
      );
    } else {
      await vm.rechazar(
        idSolicitud: solicitud.idSolicitud,
        onExito: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Solicitud rechazada'),
            backgroundColor: AppColors.coralAccion,
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.pop(context);
        },
        onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.coralAccion,
          behavior: SnackBarBehavior.floating,
        )),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Recibir la solicitud como argumento de navegación
    final solicitud =
        ModalRoute.of(context)?.settings.arguments as SolicitudModel?;

    if (solicitud == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de solicitud')),
        body: const Center(child: Text('Solicitud no encontrada')),
      );
    }

    final vm   = context.watch<BandejaViewModel>();
    final tema = Theme.of(context);
    final estaProcesando = vm.idProcesando == solicitud.idSolicitud;

    AppLogger.navegacion('DetalleSolicitudView — ID: ${solicitud.idSolicitud}');

    return Scaffold(
      backgroundColor: AppColors.superficie0,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detalle de Solicitud'),
            Text(
              'ID: #${solicitud.idSolicitud}',
              style: tema.textTheme.labelMedium,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // Botones fijos en la parte inferior
      bottomNavigationBar: solicitud.estado == 'pendiente'
          ? _BarraAccionesWidget(
              estaProcesando: estaProcesando,
              onRechazar: () => _confirmarAccion(
                  context, solicitud, TipoAccionDialogo.rechazar),
              onAutorizar: () => _confirmarAccion(
                  context, solicitud, TipoAccionDialogo.aprobar),
            )
          : null,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            // Sección: Solicitado por
            // -----------------------------------------------------------------
            _SeccionInfoWidget(
              colorBorde: AppColors.azulCielo,
              colorFondo: AppColors.azulNube,
              colorIcono: AppColors.encabezadoOscuro,
              icono: Icons.person_rounded,
              titulo: 'Solicitado por',
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(solicitud.nombreSolicitante,
                      style: tema.textTheme.titleLarge),
                  Text(solicitud.departamentoSolicitante,
                      style: tema.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(solicitud.correoSolicitante,
                      style: tema.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Solicitud creada: ${_formatearFecha(solicitud.fechaCreacion)} '
                    '${_formatearHora(solicitud.fechaCreacion)}',
                    style: tema.textTheme.labelMedium?.copyWith(
                        color: AppColors.exitoVerde),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // -----------------------------------------------------------------
            // Sección: Información del visitante
            // -----------------------------------------------------------------
            _SeccionInfoWidget(
              colorBorde: AppColors.superficie1,
              colorFondo: AppColors.superficie0,
              colorIcono: AppColors.navyProfundo,
              icono: Icons.people_alt_rounded,
              titulo: 'Información del Visitante',
              tituloColor: AppColors.navyProfundo,
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: solicitud.visitantes.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FilaInfoWidget(etiqueta: 'Nombre', valor: v.nombreCompleto),
                      _FilaInfoWidget(etiqueta: 'Correo', valor: v.correoPersonal),
                      if (solicitud.visitantes.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.sutilCalido,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${solicitud.tipoSolicitud == 'espontanea' ? 'Grupal' : 'Individual'}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.coralAccion),
                            ),
                          ),
                        ),
                    ],
                  ),
                )).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // -----------------------------------------------------------------
            // Sección: Detalles de la visita
            // -----------------------------------------------------------------
            _SeccionInfoWidget(
              colorBorde: AppColors.superficie1,
              colorFondo: AppColors.superficie0,
              colorIcono: AppColors.navyProfundo,
              icono: Icons.description_rounded,
              titulo: 'Detalles de la Visita',
              tituloColor: AppColors.navyProfundo,
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Motivo
                  Text('Motivo', style: tema.textTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(solicitud.observaciones.isNotEmpty
                      ? solicitud.observaciones
                      : solicitud.motivoVisita,
                    style: tema.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Fecha y hora en dos columnas
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 14, color: AppColors.encabezadoOscuro),
                              const SizedBox(width: 4),
                              Text('Fecha', style: tema.textTheme.labelMedium),
                            ]),
                            Text(_formatearFecha(solicitud.fechaInicio),
                                style: tema.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.navyProfundo)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.schedule_rounded,
                                  size: 14, color: AppColors.encabezadoOscuro),
                              const SizedBox(width: 4),
                              Text('Hora', style: tema.textTheme.labelMedium),
                            ]),
                            Text(_formatearHora(solicitud.fechaInicio),
                                style: tema.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.navyProfundo)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Tolerancia de llegada
                  Text('Tolerancia de llegada', style: tema.textTheme.labelMedium),
                  Text('${solicitud.toleranciaAntes} min',
                      style: tema.textTheme.bodyMedium?.copyWith(
                          color: AppColors.navyProfundo)),

                  const SizedBox(height: AppSpacing.xs),
                  _FilaInfoWidget(etiqueta: 'Tipo', valor: solicitud.tipoSolicitud),
                  _FilaInfoWidget(etiqueta: 'Lugar', valor: solicitud.lugarEncuentro),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // -----------------------------------------------------------------
            // Banner recordatorio (solo si está pendiente)
            // -----------------------------------------------------------------
            if (solicitud.estado == 'pendiente')
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.sutilCalido,
                  borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
                  border: Border.all(color: AppColors.coralSutil),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.superficie1,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.description_rounded,
                          color: AppColors.coralPrimario, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recordatorio',
                              style: tema.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.coralPrimario)),
                          Text(
                            'Verifica que la información sea correcta antes de autorizar el acceso.',
                            style: tema.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Espacio inferior para no quedar detrás de los botones
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Widget auxiliar: sección de información
// =============================================================================

class _SeccionInfoWidget extends StatelessWidget {
  final Color      colorBorde;
  final Color      colorFondo;
  final Color      colorIcono;
  final IconData   icono;
  final String     titulo;
  final Color?     tituloColor;
  final Widget     hijo;

  const _SeccionInfoWidget({
    required this.colorBorde,
    required this.colorFondo,
    required this.colorIcono,
    required this.icono,
    required this.titulo,
    this.tituloColor,
    required this.hijo,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
        border: Border.all(color: colorBorde, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icono, size: 18, color: colorIcono),
            const SizedBox(width: 6),
            Text(
              titulo,
              style: tema.textTheme.titleLarge?.copyWith(
                  color: tituloColor ?? AppColors.encabezadoOscuro),
            ),
          ]),
          const SizedBox(height: AppSpacing.xs),
          hijo,
        ],
      ),
    );
  }
}

// =============================================================================
// Widget auxiliar: fila etiqueta–valor
// =============================================================================

class _FilaInfoWidget extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _FilaInfoWidget({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: tema.textTheme.labelMedium),
          Text(valor,
              style: tema.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.navyProfundo)),
        ],
      ),
    );
  }
}

// =============================================================================
// Widget: barra de botones fija inferior
// =============================================================================

class _BarraAccionesWidget extends StatelessWidget {
  final bool         estaProcesando;
  final VoidCallback onRechazar;
  final VoidCallback onAutorizar;

  const _BarraAccionesWidget({
    required this.estaProcesando,
    required this.onRechazar,
    required this.onAutorizar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.superficie0,
        border: Border(top: BorderSide(color: AppColors.superficie1, width: 0.5)),
      ),
      child: Row(
        children: [
          // Botón Rechazar
          Expanded(
            child: OutlinedButton.icon(
              onPressed: estaProcesando ? null : onRechazar,
              icon: const Icon(Icons.cancel_rounded, size: 18),
              label: const Text('Rechazar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.coralAccion,
                side: const BorderSide(color: AppColors.coralAccion),
                minimumSize: const Size(0, AppSpacing.alturaMinBoton),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Botón Autorizar
          Expanded(
            child: ElevatedButton.icon(
              onPressed: estaProcesando ? null : onAutorizar,
              icon: estaProcesando
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.superficie0))
                  : const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text('Autorizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.exitoVerde,
                foregroundColor: AppColors.superficie0,
                minimumSize: const Size(0, AppSpacing.alturaMinBoton),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

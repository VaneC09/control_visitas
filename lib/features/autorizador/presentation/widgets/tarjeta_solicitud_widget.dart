// =============================================================================
// Archivo    : tarjeta_solicitud_widget.dart
// Módulo     : features/autorizador/presentation/widgets
// Descripción: Tarjeta individual de solicitud en la bandeja del autorizador.
//              Muestra información resumida y botones de acción directa.
//              (MPF-OMEGA-04 7.5.4 — Tarjetas, Contenedores y Áreas Informativas).
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/solicitud_model.dart';

/// Tarjeta de solicitud de visita para la bandeja del autorizador.
/// Incluye botones de Autorizar y Rechazar directamente en la tarjeta.
class TarjetaSolicitudWidget extends StatelessWidget {
  final SolicitudModel solicitud;
  final bool estaProcesando;
  final VoidCallback onAutorizar;
  final VoidCallback onRechazar;
  final VoidCallback onVerDetalle;

  const TarjetaSolicitudWidget({
    super.key,
    required this.solicitud,
    required this.estaProcesando,
    required this.onAutorizar,
    required this.onRechazar,
    required this.onVerDetalle,
  });

  // ---------------------------------------------------------------------------
  // Helpers de formato
  // ---------------------------------------------------------------------------

  /// Formatea "2026-03-26T10:00:00" → "26 mar · 10:00"
  String _formatearFecha(String fechaIso) {
    try {
      final fecha = DateTime.parse(fechaIso);
      final dia = DateFormat('d MMM', 'es_MX').format(fecha);
      final hora = DateFormat('HH:mm').format(fecha);
      return '$dia · $hora';
    } catch (_) {
      return fechaIso;
    }
  }

  /// Primer visitante de la solicitud (para mostrar en la tarjeta).
  String get _primerVisitante => solicitud.visitantes.isNotEmpty
      ? solicitud.visitantes.first.nombreCompleto
      : 'Sin visitante';

  /// Cantidad adicional de visitantes si hay más de uno.
  String get _masVisitantes {
    final extra = solicitud.visitantes.length - 1;
    return extra > 0 ? ' +$extra más' : '';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: InkWell(
        onTap: onVerDetalle,
        borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------------
              // Fila superior: nombre visitante + badge estado
              // ---------------------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _primerVisitante + _masVisitantes,
                      style: tema.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _BadgeEstadoWidget(estado: solicitud.estado),
                ],
              ),

              const SizedBox(height: 4),

              // Motivo de visita
              Text(
                solicitud.motivoVisita,
                style: tema.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.xs),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.xs),

              // ---------------------------------------------------------------
              // Fila de solicitante
              // ---------------------------------------------------------------
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.azulNube,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: AppColors.encabezadoOscuro,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          solicitud.nombreSolicitante,
                          style: tema.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          solicitud.departamentoSolicitante,
                          style: tema.textTheme.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              // ---------------------------------------------------------------
              // Fecha y hora
              // ---------------------------------------------------------------
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.encabezadoOscuro,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatearFecha(solicitud.fechaInicio),
                    style: tema.textTheme.labelMedium,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: AppColors.encabezadoOscuro,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      solicitud.lugarEncuentro,
                      style: tema.textTheme.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // ---------------------------------------------------------------
              // Botones de acción (solo si está pendiente)
              // ---------------------------------------------------------------
              if (solicitud.estado == 'pendiente') ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    // Botón Rechazar (crítico)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: estaProcesando ? null : onRechazar,
                        icon: const Icon(Icons.cancel_rounded, size: 16),
                        label: const Text('Rechazar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.coralAccion,
                          side: const BorderSide(color: AppColors.coralAccion),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    // Botón Autorizar (éxito)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: estaProcesando ? null : onAutorizar,
                        icon: estaProcesando
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.superficie0,
                                ),
                              )
                            : const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('Autorizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.exitoVerde,
                          foregroundColor: AppColors.superficie0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Widget auxiliar: badge de estado
// =============================================================================

/// Badge pequeño que muestra el estado de la solicitud con su color semántico.
class _BadgeEstadoWidget extends StatelessWidget {
  final String estado;

  const _BadgeEstadoWidget({required this.estado});

  Color get _fondo => switch (estado) {
        'pendiente'  => const Color(0xFFFFF3CD),
        'aprobada'   => const Color(0xFFD1FAE5),
        'rechazada'  => const Color(0xFFFEE2E2),
        'cancelada'  => AppColors.superficie1,
        _            => AppColors.superficie1,
      };

  Color get _texto => switch (estado) {
        'pendiente'  => const Color(0xFF856404),
        'aprobada'   => const Color(0xFF065F46),
        'rechazada'  => const Color(0xFF991B1B),
        'cancelada'  => AppColors.grisNeutral,
        _            => AppColors.grisNeutral,
      };

  String get _etiqueta => switch (estado) {
        'pendiente'  => 'Pendiente',
        'aprobada'   => 'Aprobada',
        'rechazada'  => 'Rechazada',
        'cancelada'  => 'Cancelada',
        _            => estado,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _etiqueta,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _texto,
        ),
      ),
    );
  }
}

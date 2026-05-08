// =============================================================================
// Archivo    : tarjeta_solicitud_widget.dart
// Módulo     : features/solicitante/presentation/widgets
// Ruta       : lib/features/solicitante/presentation/widgets/tarjeta_solicitud_widget.dart
//
// CORRECCIÓN: solicitud.idEstadoSolicitud → solicitud.estado
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:control_visitas/core/config/app_colors.dart';
import 'package:control_visitas/features/autorizador/data/models/solicitud_model.dart';

/// Badge de estado de una solicitud.
class EstadoBadgeWidget extends StatelessWidget {
  final String estado;
  const EstadoBadgeWidget({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final config = _config(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icono, size: 13, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.etiqueta,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  _EstadoConfig _config(String estado) {
    // CORRECCIÓN: compara contra nombres de estado ('pendiente', 'aprobada', etc.)
    // ya no usa 'idEstadoSolicitud' sino el campo 'estado' del modelo unificado
    switch (estado.toLowerCase()) {
      case 'aprobada':
        return _EstadoConfig(
          etiqueta: 'Autorizada',
          color: const Color(0xFF2E7D32),
          icono: Icons.check_circle_outline,
        );
      case 'pendiente':
        return _EstadoConfig(
          etiqueta: 'Pendiente',
          color: const Color(0xFFE65100),
          icono: Icons.schedule,
        );
      case 'rechazada':
        return _EstadoConfig(
          etiqueta: 'Rechazada',
          color: const Color(0xFFC62828),
          icono: Icons.cancel_outlined,
        );
      case 'cancelada':
        return _EstadoConfig(
          etiqueta: 'Cancelada',
          color: const Color(0xFF757575),
          icono: Icons.block,
        );
      case 'expirada':
        return _EstadoConfig(
          etiqueta: 'Expirada',
          color: const Color(0xFF5D4037),
          icono: Icons.timer_off_outlined,
        );
      default:
        return _EstadoConfig(
          etiqueta: estado,
          color: const Color(0xFF616161),
          icono: Icons.info_outline,
        );
    }
  }
}

class _EstadoConfig {
  final String etiqueta;
  final Color color;
  final IconData icono;
  _EstadoConfig({
    required this.etiqueta,
    required this.color,
    required this.icono,
  });
}

/// Tarjeta de solicitud de visita para el dashboard del solicitante.
class TarjetaSolicitudWidget extends StatelessWidget {
  final SolicitudModel solicitud;
  final VoidCallback? onTap;

  const TarjetaSolicitudWidget({
    super.key,
    required this.solicitud,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = DateTime.tryParse(solicitud.fechaInicio);
    final fechaFmt =
        fecha != null ? DateFormat('d MMM', 'es_MX').format(fecha) : '--';
    final horaFmt =
        fecha != null ? DateFormat('HH:mm').format(fecha) : '--:--';

    final primerVisitante =
        solicitud.visitantes.isNotEmpty ? solicitud.visitantes.first : null;
    final nombreVisitante =
        primerVisitante?.nombreCompleto ?? 'Sin visitante';
    final esGrupal = solicitud.visitantes.length > 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nombreVisitante +
                        (esGrupal
                            ? ' +${solicitud.visitantes.length - 1}'
                            : ''),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // CORRECCIÓN: usa solicitud.estado (campo String del modelo unificado)
                EstadoBadgeWidget(estado: solicitud.estado),
              ],
            ),
            if (solicitud.motivoVisita.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                solicitud.motivoVisita,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(fechaFmt,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(horaFmt,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                if (solicitud.lugarEncuentro.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.location_on_outlined,
                      size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      solicitud.lugarEncuentro,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
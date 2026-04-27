// =============================================================================
// Archivo: detalle_solicitud_solicitante_view.dart
// Módulo: solicitante/presentation/views
// Descripción: Vista de detalle de una solicitud para el solicitante.
// Autor: OMEGA Solutions
// Versión: 1.0
// Fecha: 2026-04-26
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../bloc/solicitante_provider.dart';
import '../widgets/tarjeta_solicitud_widget.dart';

/// Vista de detalle de solicitud del solicitante.
class DetalleSolicitudSolicitanteView extends StatefulWidget {
  final int idSolicitud;

  const DetalleSolicitudSolicitanteView({
    super.key,
    required this.idSolicitud,
  });

  @override
  State<DetalleSolicitudSolicitanteView> createState() =>
      _DetalleSolicitudSolicitanteViewState();
}

class _DetalleSolicitudSolicitanteViewState
    extends State<DetalleSolicitudSolicitanteView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolicitanteProvider>().cargarDetalle(widget.idSolicitud);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE07A5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detalle de Solicitud',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<SolicitanteProvider>(
        builder: (context, provider, _) {
          if (provider.estadoDetalle == EstadoCarga.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.estadoDetalle == EstadoCarga.error) {
            return Center(
              child: Text(
                provider.errorDetalle,
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          final solicitud = provider.solicitudDetalle;
          if (solicitud == null) return const SizedBox();

          final fecha = DateTime.tryParse(solicitud.fechaInicio);
          final fechaFmt = fecha != null
              ? DateFormat('d \'de\' MMMM \'de\' yyyy', 'es_MX').format(fecha)
              : '--';
          final horaFmt =
              fecha != null ? DateFormat('HH:mm').format(fecha) : '--:--';

          final puedeCancel = solicitud.idEstadoSolicitud == 'pendiente' ||
              solicitud.idEstadoSolicitud == 'aprobada';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card estado
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estado',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          EstadoBadgeWidget(
                              estado: solicitud.idEstadoSolicitud),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Folio',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            'SOL-${solicitud.idSolicitud?.toString().padLeft(4, '0') ?? '----'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card fecha y hora
                _CardInfo(
                  titulo: 'Fecha y hora',
                  items: [
                    _ItemInfo(
                        icono: Icons.calendar_today_outlined,
                        label: 'Fecha',
                        valor: fechaFmt),
                    _ItemInfo(
                        icono: Icons.access_time,
                        label: 'Hora',
                        valor: horaFmt),
                    _ItemInfo(
                      icono: Icons.timer_outlined,
                      label: 'Tolerancia',
                      valor:
                          '${solicitud.toleranciaAntes} min antes / ${solicitud.toleranciaDespues} min después',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card visitantes
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visitantes (${solicitud.visitantes.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...solicitud.visitantes.map((v) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFFFAEFED),
                                  child: Icon(Icons.person_outline,
                                      color: Color(0xFFE07A5F), size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(v.nombreCompleto,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          )),
                                      Text(v.correoPersonal,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón cancelar
                if (puedeCancel)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmarCancelacion(context, provider),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.cancel_outlined,
                          color: Colors.red, size: 18),
                      label: const Text('Cancelar solicitud',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmarCancelacion(
      BuildContext context, SolicitanteProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cancelar solicitud?'),
        content: const Text(
          'Esta acción invalidará los QR generados y notificará al visitante.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final exito = await provider.cancelarSolicitud(widget.idSolicitud);
              if (!mounted) return;
              if (exito) Navigator.of(context).pop();
            },
            child: const Text('Sí, cancelar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  final String titulo;
  final List<_ItemInfo> items;

  const _CardInfo({required this.titulo, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(item.icono,
                        size: 16, color: const Color(0xFFE07A5F)),
                    const SizedBox(width: 8),
                    Text('${item.label}: ',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                    Expanded(
                      child: Text(item.valor,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ItemInfo {
  final IconData icono;
  final String label;
  final String valor;
  const _ItemInfo(
      {required this.icono, required this.label, required this.valor});
}

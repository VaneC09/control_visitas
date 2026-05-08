// =============================================================================
// Archivo    : qr_display_widget.dart
// Módulo     : features/solicitante/presentation/widgets
// Descripción: Widget que muestra el código QR generado para un visitante.
//              Usa qr_flutter para renderizar el QR visual.
//              El solicitante puede compartir el código o mostrar la imagen.
// Ruta       : lib/features/solicitante/presentation/widgets/qr_display_widget.dart
//
// DEPENDENCIA REQUERIDA en pubspec.yaml:
//   qr_flutter: ^4.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:control_visitas/core/config/app_colors.dart';
import 'package:control_visitas/core/constants/app_spacing.dart';
import 'package:control_visitas/features/autorizador/data/repositories/solicitud_repositorio_local.dart';

/// Pantalla / sheet que muestra el QR de una solicitud aprobada.
/// Llámala desde el detalle de solicitud cuando estado == 'aprobada'.
///
/// Uso:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (_) => QrDisplayWidget(idSolicitud: solicitud.idSolicitud),
/// );
/// ```
class QrDisplayWidget extends StatefulWidget {
  final int idSolicitud;

  const QrDisplayWidget({super.key, required this.idSolicitud});

  @override
  State<QrDisplayWidget> createState() => _QrDisplayWidgetState();
}

class _QrDisplayWidgetState extends State<QrDisplayWidget> {
  final _repo = SolicitudRepositorioLocal();
  List<Map<String, dynamic>> _qrs = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarQrs();
  }

  Future<void> _cargarQrs() async {
    setState(() => _cargando = true);
    try {
      final lista = await _repo.obtenerQrsDeSolicitud(widget.idSolicitud);
      setState(() {
        _qrs      = lista;
        _cargando = false;
      });
    } catch (_) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.superficie0,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.superficie1,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Text('Códigos QR de acceso', style: tema.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Muestra o comparte estos códigos con tus visitantes.',
            style: tema.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          if (_cargando)
            const CircularProgressIndicator(color: AppColors.coralPrimario)
          else if (_qrs.isEmpty)
            Text('Sin QRs disponibles.', style: tema.textTheme.bodyMedium)
          else
            ..._qrs.map((qr) => _TarjetaQr(qr: qr)),
        ],
      ),
    );
  }
}

class _TarjetaQr extends StatelessWidget {
  final Map<String, dynamic> qr;
  const _TarjetaQr({required this.qr});

  @override
  Widget build(BuildContext context) {
    final tema     = Theme.of(context);
    final codigo   = qr['codigo_numerico'] as String? ?? '';
    final nombre   = '${qr["nombre_visitante"] ?? ""} ${qr["apellidos_visitante"] ?? ""}'.trim();
    final correo   = qr['correo_personal'] as String? ?? '';
    final estadoQr = qr['estado_qr']       as String? ?? 'activo';
    final vigFin   = qr['vigencia_final']  as String? ?? '';

    // Formatear hora de vigencia
    String vigenciaTexto = '';
    try {
      final dt = DateTime.parse(vigFin);
      vigenciaTexto =
          'Válido hasta ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) {}

    final esValido = estadoQr == 'activo' || estadoQr == 'extendido';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: esValido ? AppColors.superficie0 : AppColors.superficie1,
        borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
        border: Border.all(
          color: esValido ? AppColors.coralPrimario : AppColors.superficie1,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Info del visitante
          Row(
            children: [
              const Icon(Icons.person_rounded,
                  color: AppColors.encabezadoOscuro, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: tema.textTheme.bodyMedium?.copyWith(
                        color: AppColors.navyProfundo,
                        fontWeight: FontWeight.w600)),
                    Text(correo, style: tema.textTheme.labelMedium),
                  ],
                ),
              ),
              // Badge de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: esValido
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  esValido ? 'Activo' : estadoQr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: esValido
                        ? AppColors.exitoVerde
                        : AppColors.coralAccion,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Imagen QR (solo si activo)
          if (esValido && codigo.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.superficie1),
              ),
              child: QrImageView(
                data: codigo,
                version: QrVersions.auto,
                size: 200,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.navyProfundo,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.navyProfundo,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Código en texto (para leerlo manualmente)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.sutilCalido,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text('Código de acceso',
                    style: tema.textTheme.labelMedium),
                const SizedBox(height: 4),
                SelectableText(
                  codigo,
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyProfundo,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (vigenciaTexto.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(vigenciaTexto,
                      style: tema.textTheme.labelMedium?.copyWith(
                          color: AppColors.exitoVerde)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
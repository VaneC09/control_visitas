// =============================================================================
// Archivo    : dialogo_confirmacion_widget.dart
// Módulo     : features/autorizador/presentation/widgets
// Descripción: Diálogo modal de confirmación para aprobar o rechazar una
//              solicitud. Primera acción definitiva — avisa al usuario.
//              (MPF-OMEGA-04 7.4.3 — Criterios de uso para alertas modales).
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Tipo de acción que ejecutará el diálogo.
enum TipoAccionDialogo { aprobar, rechazar }

/// Diálogo modal de confirmación de acción sobre una solicitud.
///
/// Uso:
/// ```dart
/// final confirmo = await DialogoConfirmacionWidget.mostrar(
///   context: context,
///   tipo: TipoAccionDialogo.aprobar,
///   nombreSolicitante: 'Ing. Roberto Sánchez',
/// );
/// if (confirmo == true) { ... }
/// ```
class DialogoConfirmacionWidget extends StatelessWidget {
  final TipoAccionDialogo tipo;
  final String nombreSolicitante;
  final bool estaProcesando;

  const DialogoConfirmacionWidget({
    super.key,
    required this.tipo,
    required this.nombreSolicitante,
    this.estaProcesando = false,
  });

  // ---------------------------------------------------------------------------
  // Método estático de conveniencia para mostrar el diálogo
  // ---------------------------------------------------------------------------

  /// Muestra el diálogo y retorna [true] si el usuario confirmó, [false] si canceló.
  static Future<bool?> mostrar({
    required BuildContext context,
    required TipoAccionDialogo tipo,
    required String nombreSolicitante,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,  // No se cierra tocando fuera
      builder: (_) => DialogoConfirmacionWidget(
        tipo: tipo,
        nombreSolicitante: nombreSolicitante,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Configuración visual por tipo
  // ---------------------------------------------------------------------------

  bool get _esAprobar => tipo == TipoAccionDialogo.aprobar;

  Color get _colorIcono => _esAprobar ? AppColors.exitoVerde : AppColors.coralAccion;
  Color get _colorFondoIcono =>
      _esAprobar ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
  IconData get _icono =>
      _esAprobar ? Icons.check_circle_rounded : Icons.cancel_rounded;
  String get _titulo => _esAprobar ? 'Aprobar solicitud' : 'Rechazar solicitud';
  String get _mensaje =>
      '¿Desea ${_esAprobar ? "aprobar" : "rechazar"} la solicitud de '
      '$nombreSolicitante?\n\nEsta acción es definitiva y no puede revertirse.';
  String get _textoBotonConfirmar => _esAprobar ? 'Confirmar' : 'Rechazar';
  Color get _colorBotonConfirmar =>
      _esAprobar ? AppColors.exitoVerde : AppColors.coralAccion;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.superficie0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono circular
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _colorFondoIcono,
                shape: BoxShape.circle,
              ),
              child: Icon(_icono, color: _colorIcono, size: 32),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Título
            Text(
              _titulo,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xs),

            // Mensaje descriptivo
            Text(
              _mensaje,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.md),

            // Botones
            Row(
              children: [
                // Botón Cancelar (secundario)
                Expanded(
                  child: OutlinedButton(
                    onPressed: estaProcesando
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                ),

                const SizedBox(width: AppSpacing.xs),

                // Botón Confirmar (primario / crítico)
                Expanded(
                  child: ElevatedButton(
                    onPressed: estaProcesando
                        ? null
                        : () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorBotonConfirmar,
                      foregroundColor: AppColors.superficie0,
                    ),
                    child: estaProcesando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.superficie0,
                            ),
                          )
                        : Text(_textoBotonConfirmar),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

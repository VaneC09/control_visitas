// ==============================================================
// Archivo    : estado_error_widget.dart
// Descripción: Widget reutilizable para estados de error.
//              Muestra mensaje claro y botón de reintento.
// ==============================================================
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../constants/app_spacing.dart';

class EstadoErrorWidget extends StatelessWidget {
  final String       mensaje;
  final VoidCallback onReintentar;
  final IconData     icono;

  const EstadoErrorWidget({
    super.key,
    required this.mensaje,
    required this.onReintentar,
    this.icono = Icons.wifi_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 52, color: AppColors.encabezadoOscuro),
            const SizedBox(height: AppSpacing.sm),
            Text('Algo salió mal',
                style: tema.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(mensaje,
                style: tema.textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}

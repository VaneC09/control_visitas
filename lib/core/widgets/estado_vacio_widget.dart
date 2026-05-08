import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../constants/app_spacing.dart';

class EstadoVacioWidget extends StatelessWidget {
  final String  titulo;
  final String  descripcion;
  final IconData icono;
  final Widget?  accion;

  const EstadoVacioWidget({
    super.key,
    required this.titulo,
    required this.descripcion,
    this.icono = Icons.inbox_rounded,
    this.accion,
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
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                color: AppColors.superficie1,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 36,
                  color: AppColors.encabezadoOscuro),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(titulo,
                style: tema.textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(descripcion,
                style: tema.textTheme.bodyMedium,
                textAlign: TextAlign.center),
            if (accion != null) ...[
              const SizedBox(height: AppSpacing.sm),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}

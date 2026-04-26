// =============================================================================
// Archivo    : seleccion_rol_view.dart
// Módulo     : features/autorizador/presentation/views
// Descripción: Pantalla 0 — Selección del tipo de usuario antes del login.
//              Muestra los tres roles del sistema. Solo el rol Autorizador
//              está habilitado en esta versión.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../bloc/auth_viewmodel.dart';

/// Pantalla de selección de rol antes del login institucional.
class SeleccionRolView extends StatelessWidget {
  const SeleccionRolView({super.key});

  // ---------------------------------------------------------------------------
  // Build principal
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final tema   = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.superficie0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // ---------------------------------------------------------------
              // Logo institucional
              // ---------------------------------------------------------------
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.coralPrimario,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppColors.superficie0,
                  size: 44,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Título y subtítulo
              Text(
                'Sistema de Gestión de Accesos',
                style: tema.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Control de Visitas',
                style: tema.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.lg),

              // ---------------------------------------------------------------
              // Panel de selección de rol
              // ---------------------------------------------------------------
              Container(
                decoration: BoxDecoration(
                  color: AppColors.superficie0,
                  borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
                  border: Border.all(color: AppColors.superficie1),
                ),
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecciona tu rol',
                      style: tema.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Rol: Solicitante (deshabilitado en esta versión)
                    _TarjetaRolWidget(
                      icono: Icons.work_rounded,
                      colorIcono: const Color(0xFFFF8C00),
                      colorFondoIcono: const Color(0xFFFFF3E0),
                      titulo: 'Solicitante',
                      subtitulo: 'Empleado',
                      seleccionado: false,
                      habilitado: false,
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),

                    // Rol: Autorizador (habilitado)
                    _TarjetaRolWidget(
                      icono: Icons.people_alt_rounded,
                      colorIcono: AppColors.encabezadoOscuro,
                      colorFondoIcono: AppColors.azulNube,
                      titulo: 'Autorizador',
                      subtitulo: 'Jefe / Recursos Materiales',
                      seleccionado: authVM.rolSeleccionado == 'autorizador',
                      habilitado: true,
                      onTap: () {
                        context.read<AuthViewModel>().seleccionarRol('autorizador');
                        AppLogger.navegacion('Rol autorizador seleccionado');
                      },
                    ),
                    const SizedBox(height: 8),

                    // Rol: Vigilante (deshabilitado en esta versión)
                    _TarjetaRolWidget(
                      icono: Icons.shield_rounded,
                      colorIcono: AppColors.exitoVerde,
                      colorFondoIcono: const Color(0xFFD1FAE5),
                      titulo: 'Vigilante',
                      subtitulo: 'Seguridad',
                      seleccionado: false,
                      habilitado: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ---------------------------------------------------------------
              // Botón Iniciar sesión
              // ---------------------------------------------------------------
              ElevatedButton(
                onPressed: authVM.rolSeleccionado == 'autorizador'
                    ? () {
                        AppLogger.navegacion(AppRoutes.login);
                        Navigator.pushNamed(context, AppRoutes.login);
                      }
                    : null,
                child: const Text('Iniciar Sesión'),
              ),

              const SizedBox(height: AppSpacing.xs),

              // Nota informativa
              Text(
                'Solo el rol Autorizador está disponible en esta versión.',
                style: tema.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Widget auxiliar: tarjeta de rol
// =============================================================================

class _TarjetaRolWidget extends StatelessWidget {
  final IconData icono;
  final Color    colorIcono;
  final Color    colorFondoIcono;
  final String   titulo;
  final String   subtitulo;
  final bool     seleccionado;
  final bool     habilitado;
  final VoidCallback onTap;

  const _TarjetaRolWidget({
    required this.icono,
    required this.colorIcono,
    required this.colorFondoIcono,
    required this.titulo,
    required this.subtitulo,
    required this.seleccionado,
    required this.habilitado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Opacity(
      opacity: habilitado ? 1.0 : 0.45,
      child: InkWell(
        onTap: habilitado ? onTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.radioBorde),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.superficie0,
            borderRadius: BorderRadius.circular(AppSpacing.radioBorde),
            border: Border.all(
              color: seleccionado
                  ? AppColors.coralPrimario
                  : AppColors.superficie1,
              width: seleccionado ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              // Ícono del rol
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorFondoIcono,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: colorIcono, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: tema.textTheme.bodyMedium?.copyWith(
                      color: AppColors.navyProfundo,
                      fontWeight: FontWeight.w600,
                    )),
                    Text(subtitulo, style: tema.textTheme.labelMedium),
                  ],
                ),
              ),
              // Radio visual
              Radio<bool>(
                value: true,
                groupValue: seleccionado ? true : null,
                onChanged: habilitado ? (_) => onTap() : null,
                activeColor: AppColors.coralPrimario,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

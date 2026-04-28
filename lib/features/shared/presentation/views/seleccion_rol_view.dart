// =============================================================================
// Archivo    : seleccion_rol_view.dart
// Módulo     : features/shared/presentation/views
// Descripción: Pantalla 0 — Selección del tipo de usuario antes del login.
//              Los tres roles están habilitados en esta versión.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.2.0
// Fecha      : 2026-04-27
// Cambios    : v1.1.0 — Solicitante habilitado
//              v1.2.0 — Vigilante habilitado; rutas corregidas a loginAutorizador
//                       y loginVigilante; se elimina dependencia de AuthViewModel
//                       para el rol vigilante (tiene su propio VigilanteViewModel)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../autorizador/bloc/auth_viewmodel.dart';

/// Pantalla de selección de rol antes del login institucional.
class SeleccionRolView extends StatefulWidget {
  const SeleccionRolView({super.key});

  @override
  State<SeleccionRolView> createState() => _SeleccionRolViewState();
}

class _SeleccionRolViewState extends State<SeleccionRolView> {
  /// El rol seleccionado se gestiona localmente para no mezclar
  /// el AuthViewModel del autorizador con el rol vigilante.
  String _rolSeleccionado = '';

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

              // Logo institucional
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

              // Panel de roles
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
                    Text('Selecciona tu rol', style: tema.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Rol: Solicitante (habilitado) ──────────────────────
                    _TarjetaRolWidget(
                      icono:           Icons.work_rounded,
                      colorIcono:      const Color(0xFFFF8C00),
                      colorFondoIcono: const Color(0xFFFFF3E0),
                      titulo:          'Solicitante',
                      subtitulo:       'Empleado',
                      seleccionado:    _rolSeleccionado == 'solicitante',
                      habilitado:      true,
                      onTap: () {
                        setState(() => _rolSeleccionado = 'solicitante');
                        // Sincronizar AuthViewModel solo para autorizador/solicitante
                        context.read<AuthViewModel>().seleccionarRol('solicitante');
                        AppLogger.accionUsuario('Rol solicitante seleccionado');
                      },
                    ),
                    const SizedBox(height: 8),

                    // ── Rol: Autorizador (habilitado) ──────────────────────
                    _TarjetaRolWidget(
                      icono:           Icons.people_alt_rounded,
                      colorIcono:      AppColors.encabezadoOscuro,
                      colorFondoIcono: AppColors.azulNube,
                      titulo:          'Autorizador',
                      subtitulo:       'Jefe / Recursos Materiales',
                      seleccionado:    _rolSeleccionado == 'autorizador',
                      habilitado:      true,
                      onTap: () {
                        setState(() => _rolSeleccionado = 'autorizador');
                        context.read<AuthViewModel>().seleccionarRol('autorizador');
                        AppLogger.accionUsuario('Rol autorizador seleccionado');
                      },
                    ),
                    const SizedBox(height: 8),

                    // ── Rol: Vigilante (habilitado) ────────────────────────
                    _TarjetaRolWidget(
                      icono:           Icons.shield_rounded,
                      colorIcono:      AppColors.exitoVerde,
                      colorFondoIcono: const Color(0xFFD1FAE5),
                      titulo:          'Vigilante',
                      subtitulo:       'Seguridad',
                      seleccionado:    _rolSeleccionado == 'vigilante',
                      habilitado:      true,
                      onTap: () {
                        setState(() => _rolSeleccionado = 'vigilante');
                        // El vigilante tiene su propio ViewModel; no se toca AuthViewModel
                        AppLogger.accionUsuario('Rol vigilante seleccionado');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Botón Iniciar sesión — habilitado si hay cualquier rol seleccionado
              ElevatedButton(
                onPressed: _rolSeleccionado.isNotEmpty
                    ? () => _navegarSegunRol(context, _rolSeleccionado)
                    : null,
                child: const Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navega a la pantalla de login correspondiente al rol elegido.
  void _navegarSegunRol(BuildContext context, String rol) {
    switch (rol) {
      case 'autorizador':
        AppLogger.navegacion(AppRoutes.loginAutorizador);
        Navigator.pushNamed(context, AppRoutes.loginAutorizador);
        break;
      case 'solicitante':
        AppLogger.navegacion(AppRoutes.dashboardSolicitante);
        Navigator.pushNamed(context, AppRoutes.dashboardSolicitante);
        break;
      case 'vigilante':
        // El vigilante va directamente a su propio login con validación de teléfono
        AppLogger.navegacion(AppRoutes.loginVigilante);
        Navigator.pushNamed(context, AppRoutes.loginVigilante);
        break;
    }
  }
}

// =============================================================================
// Widget auxiliar: tarjeta de rol
// =============================================================================

class _TarjetaRolWidget extends StatelessWidget {
  final IconData     icono;
  final Color        colorIcono;
  final Color        colorFondoIcono;
  final String       titulo;
  final String       subtitulo;
  final bool         seleccionado;
  final bool         habilitado;
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
                    Text(
                      titulo,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color:      AppColors.navyProfundo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(subtitulo, style: tema.textTheme.labelMedium),
                  ],
                ),
              ),
              // Radio de selección
              Radio<bool>(
                value:      true,
                groupValue: seleccionado ? true : null,
                onChanged:  habilitado ? (_) => onTap() : null,
                activeColor: AppColors.coralPrimario,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

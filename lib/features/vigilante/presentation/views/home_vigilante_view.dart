// =============================================================================
// Archivo    : home_vigilante_view.dart
// Módulo     : features/vigilante/presentation/views
// Descripción: Pantalla 1 — Home del vigilante. Tres acciones principales:
//              Escanear QR, Visita Espontánea, Próximas Visitas.
//              Diseño para uso con una sola mano. Máx 2 pasos por acción.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-27
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../bloc/vigilante_viewmodel.dart';
import 'escaner_qr_view.dart';
import 'login_vigilante_view.dart';
import 'proximas_visitas_view.dart';
import 'visita_espontanea_view.dart';

/// Pantalla Home del vigilante con las tres acciones principales.
class HomeVigilanteView extends StatelessWidget {
  const HomeVigilanteView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<VigilanteViewModel>();
    final tema = Theme.of(context);
    final ahora = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.superficie0,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Control de Accesos'),
            Text(DateFormat("EEEE d 'de' MMMM", 'es_MX').format(ahora),
                style: tema.textTheme.labelMedium),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'salir') {
                await vm.logout();
                if (!context.mounted) return;
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginVigilanteView()));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'info',
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vm.vigilante?.nombreCompleto ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600,
                            color: AppColors.navyProfundo)),
                    Text('Vigilante',
                        style: const TextStyle(fontSize: 12,
                            color: AppColors.encabezadoOscuro)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'salir',
                  child: Row(children: [
                    Icon(Icons.logout_rounded, size: 18),
                    SizedBox(width: 8), Text('Cerrar sesión'),
                  ])),
            ],
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.exitoVerde,
                  borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
                ),
                child: Row(children: [
                  const Icon(Icons.security_rounded,
                      color: AppColors.superficie0, size: 32),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bienvenido, ${vm.vigilante?.nombre ?? 'Vigilante'}',
                            style: const TextStyle(color: AppColors.superficie0,
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(DateFormat('HH:mm').format(ahora),
                            style: const TextStyle(color: AppColors.superficie0,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: AppSpacing.sm),
              Text('Acciones', style: tema.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),

              // Botón principal — Escanear QR (más grande, destacado)
              _BotonAccionWidget(
                icono:     Icons.qr_code_scanner_rounded,
                titulo:    'Escanear QR',
                subtitulo: 'Registrar entrada o salida',
                colorFondo:AppColors.exitoVerde,
                colorTexto:AppColors.superficie0,
                esGrande:  true,
                onTap: () {
                  AppLogger.navegacion('EscanerQrView');
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const EscanerQrView()));
                },
              ),

              const SizedBox(height: AppSpacing.xs),

              // Segunda fila: dos botones menores
              Row(children: [
                Expanded(
                  child: _BotonAccionWidget(
                    icono:     Icons.person_add_rounded,
                    titulo:    'Registro rápido',
                    subtitulo: 'Visita sin cita',
                    colorFondo:AppColors.coralPrimario,
                    colorTexto:AppColors.superficie0,
                    esGrande:  false,
                    onTap: () {
                      AppLogger.navegacion('VisitaEspontaneaView');
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const VisitaEspontaneaView()));
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _BotonAccionWidget(
                    icono:     Icons.calendar_today_rounded,
                    titulo:    'Próximas visitas',
                    subtitulo: 'Lista del día',
                    colorFondo:AppColors.encabezadoOscuro,
                    colorTexto:AppColors.superficie0,
                    esGrande:  false,
                    onTap: () {
                      AppLogger.navegacion('ProximasVisitasView');
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const ProximasVisitasView()));
                    },
                  ),
                ),
              ]),

              const SizedBox(height: AppSpacing.sm),

              // Información del turno
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.superficie1,
                  borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
                  border: Border.all(color: AppColors.superficie1, width: 0.5),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.encabezadoOscuro, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recuerda: verifica la credencial del visitante antes de permitir el acceso.',
                      style: tema.textTheme.labelMedium,
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Widget: botón de acción del home
// =============================================================================

class _BotonAccionWidget extends StatelessWidget {
  final IconData icono;
  final String   titulo;
  final String   subtitulo;
  final Color    colorFondo;
  final Color    colorTexto;
  final bool     esGrande;
  final VoidCallback onTap;

  const _BotonAccionWidget({
    required this.icono, required this.titulo, required this.subtitulo,
    required this.colorFondo, required this.colorTexto,
    required this.esGrande, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(esGrande ? AppSpacing.sm : AppSpacing.xs + 4),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
        ),
        child: esGrande
            ? Row(children: [
                Icon(icono, color: colorTexto, size: 36),
                const SizedBox(width: AppSpacing.xs),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(titulo, style: TextStyle(color: colorTexto,
                      fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitulo, style: TextStyle(color: colorTexto.withOpacity(.8),
                      fontSize: 12)),
                ]),
              ])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icono, color: colorTexto, size: 28),
                  const SizedBox(height: 6),
                  Text(titulo, style: TextStyle(color: colorTexto,
                      fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(subtitulo, style: TextStyle(color: colorTexto.withOpacity(.8),
                      fontSize: 11)),
                ],
              ),
      ),
    );
  }
}

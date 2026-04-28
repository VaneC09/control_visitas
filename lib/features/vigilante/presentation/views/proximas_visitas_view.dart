// =============================================================================
// Archivo    : proximas_visitas_view.dart
// Módulo     : features/vigilante/presentation/views
// Descripción: Pantalla 6 — Lista de visitas aprobadas para el día de hoy.
//              Incluye filtros por área y estado, y búsqueda libre.
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
import '../../data/models/visita_hoy_model.dart';

/// Pantalla de próximas visitas del día para el vigilante.
class ProximasVisitasView extends StatefulWidget {
  const ProximasVisitasView({super.key});

  @override
  State<ProximasVisitasView> createState() => _ProximasVisitasViewState();
}

class _ProximasVisitasViewState extends State<ProximasVisitasView> {
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VigilanteViewModel>().cargarVisitasHoy();
      AppLogger.navegacion('ProximasVisitasView');
    });
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<VigilanteViewModel>();
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.superficie0,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Próximas Visitas'),
            Text(
              DateFormat("d 'de' MMMM 'de' yyyy", 'es_MX').format(DateTime.now()),
              style: tema.textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<VigilanteViewModel>().cargarVisitasHoy(),
          ),
        ],
      ),

      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, 0),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: context.read<VigilanteViewModel>().filtrarVisitas,
              decoration: InputDecoration(
                hintText: 'Buscar visitante, anfitrión, área...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _busquedaCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _busquedaCtrl.clear();
                          context.read<VigilanteViewModel>().filtrarVisitas('');
                        })
                    : null,
              ),
            ),
          ),

          // Contador
          if (vm.estadoVisitasHoy == EstadoVigilante.exitoso)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, 8, AppSpacing.sm, 0),
              child: Row(
                children: [
                  Text(
                    '${vm.visitasFiltradas.length} visita(s) para hoy',
                    style: tema.textTheme.labelMedium,
                  ),
                ],
              ),
            ),

          // Contenido
          Expanded(child: _construirContenido(context, vm)),
        ],
      ),
    );
  }

  Widget _construirContenido(BuildContext context, VigilanteViewModel vm) {
    switch (vm.estadoVisitasHoy) {
      case EstadoVigilante.cargando:
        return const Center(child: CircularProgressIndicator(
            color: AppColors.exitoVerde));

      case EstadoVigilante.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.wifi_off_rounded, size: 48,
                  color: AppColors.encabezadoOscuro),
              const SizedBox(height: AppSpacing.xs),
              const Text('Sin conexión'),
              const SizedBox(height: AppSpacing.xs),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<VigilanteViewModel>().cargarVisitasHoy(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.exitoVerde,
                    foregroundColor: AppColors.superficie0),
              ),
            ]),
          ),
        );

      case EstadoVigilante.exitoso:
        if (vm.visitasFiltradas.isEmpty) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.event_busy_rounded, size: 52,
                  color: AppColors.encabezadoOscuro),
              const SizedBox(height: AppSpacing.xs),
              const Text('Sin visitas para hoy',
                  style: TextStyle(fontWeight: FontWeight.w500,
                      color: AppColors.navyProfundo)),
              const SizedBox(height: 6),
              const Text('No hay visitas programadas\npara el día de hoy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.encabezadoOscuro)),
            ]),
          );
        }

        return RefreshIndicator(
          color: AppColors.exitoVerde,
          onRefresh: () => context.read<VigilanteViewModel>().cargarVisitasHoy(),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.sm),
            itemCount: vm.visitasFiltradas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) =>
                _TarjetaVisitaHoyWidget(visita: vm.visitasFiltradas[i]),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// =============================================================================
// Tarjeta de visita individual
// =============================================================================

class _TarjetaVisitaHoyWidget extends StatelessWidget {
  final VisitaHoyModel visita;
  const _TarjetaVisitaHoyWidget({required this.visita});

  Color get _colorEstadoQr => switch (visita.estadoQr) {
    'pendiente'  => const Color(0xFFFFF3CD),
    'en_camino'  => AppColors.azulNube,
    'en_reunion' => const Color(0xFFD1FAE5),
    'finalizado' => AppColors.superficie1,
    'expirado'   => const Color(0xFFFEE2E2),
    _            => AppColors.superficie1,
  };

  Color get _textoEstadoQr => switch (visita.estadoQr) {
    'pendiente'  => const Color(0xFF856404),
    'en_camino'  => AppColors.navyProfundo,
    'en_reunion' => const Color(0xFF065F46),
    'finalizado' => AppColors.grisNeutral,
    'expirado'   => const Color(0xFF991B1B),
    _            => AppColors.grisNeutral,
  };

  String get _etiquetaEstado => switch (visita.estadoQr) {
    'pendiente'  => 'Pendiente',
    'en_camino'  => 'En camino',
    'en_reunion' => 'En reunión',
    'finalizado' => 'Finalizado',
    'expirado'   => 'Expirado',
    'cancelado'  => 'Cancelado',
    _            => visita.estadoQr,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila: nombre visitante + estado QR
            Row(children: [
              Expanded(
                child: Text(visita.nombreVisitante.isNotEmpty
                    ? visita.nombreVisitante : 'Visitante',
                  style: const TextStyle(fontWeight: FontWeight.w600,
                      color: AppColors.navyProfundo, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _colorEstadoQr,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_etiquetaEstado,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                        color: _textoEstadoQr)),
              ),
            ]),

            const SizedBox(height: 4),

            // Hora
            Row(children: [
              const Icon(Icons.schedule_rounded, size: 13,
                  color: AppColors.encabezadoOscuro),
              const SizedBox(width: 4),
              Text(visita.hora,
                  style: const TextStyle(fontSize: 13,
                      color: AppColors.encabezadoOscuro,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.location_on_rounded, size: 13,
                  color: AppColors.encabezadoOscuro),
              const SizedBox(width: 4),
              Text(visita.lugarEncuentro,
                  style: const TextStyle(fontSize: 13,
                      color: AppColors.encabezadoOscuro)),
            ]),

            const SizedBox(height: 4),
            const Divider(height: 1),
            const SizedBox(height: 4),

            // Anfitrión
            Row(children: [
              const Icon(Icons.person_rounded, size: 14,
                  color: AppColors.azulCielo),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${visita.nombreAnfitrion} · ${visita.departamento}',
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.encabezadoOscuro),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),

            // Código QR (pequeño, para referencia del vigilante)
            if (visita.codigoQr.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('QR: ${visita.codigoQr}',
                  style: const TextStyle(fontSize: 11,
                      color: AppColors.azulCielo,
                      fontFamily: 'monospace')),
            ],
          ],
        ),
      ),
    );
  }
}

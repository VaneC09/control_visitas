// =============================================================================
// Archivo    : espera_prorroga_view.dart
// Módulo     : features/vigilante/presentation/views
// Descripción: Pantalla 4 — Estado de espera mientras se resuelve una
//              solicitud de prórroga. Polling automático cada 5 segundos.
//              Timeout máximo: 3 minutos (180 segundos).
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-27
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../bloc/vigilante_viewmodel.dart';
import 'home_vigilante_view.dart';

/// Pantalla de espera de respuesta a la solicitud de prórroga.
class EsperaProrrorgaView extends StatefulWidget {
  const EsperaProrrorgaView({super.key});

  @override
  State<EsperaProrrorgaView> createState() => _EsperaProrrorgaViewState();
}

class _EsperaProrrorgaViewState extends State<EsperaProrrorgaView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VigilanteViewModel>().solicitarProrroga(
        onAprobada: () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Prórroga aprobada. Vuelva a escanear.'),
                backgroundColor: AppColors.exitoVerde,
                behavior: SnackBarBehavior.floating, duration: Duration(seconds: 4)),
          );
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const HomeVigilanteView()));
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<VigilanteViewModel>();
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.superficie0,
      appBar: AppBar(
        title: const Text('Solicitud de Prórroga'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            vm.cancelarProrroga();
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Estado visual
            _construirIconoEstado(vm.estadoProrroga),
            const SizedBox(height: AppSpacing.md),

            // Título
            Text(_tituloEstado(vm.estadoProrroga),
                style: tema.textTheme.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),

            // Descripción
            Text(_descripcionEstado(vm.estadoProrroga),
                style: tema.textTheme.bodyMedium,
                textAlign: TextAlign.center),

            if (vm.estadoProrroga == EstadoProrroga.esperando) ...[
              const SizedBox(height: AppSpacing.md),
              // Contador de espera
              Text(
                'Esperando respuesta... ${_maxEspera - vm.segundosEsperaProrroga}s',
                style: tema.textTheme.labelMedium?.copyWith(
                    color: AppColors.coralPrimario),
              ),
              const SizedBox(height: AppSpacing.xs),
              LinearProgressIndicator(
                value: vm.segundosEsperaProrroga / _maxEspera,
                backgroundColor: AppColors.superficie1,
                color: AppColors.coralPrimario,
                borderRadius: BorderRadius.circular(4),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Botón según estado
            if (vm.estadoProrroga == EstadoProrroga.rechazada ||
                vm.estadoProrroga == EstadoProrroga.timeout)
              ElevatedButton(
                onPressed: () {
                  vm.cancelarProrroga();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(
                          builder: (_) => const HomeVigilanteView()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coralAccion,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Volver al inicio',
                    style: TextStyle(color: AppColors.superficie0)),
              ),

            if (vm.estadoProrroga == EstadoProrroga.esperando)
              OutlinedButton(
                onPressed: () {
                  vm.cancelarProrroga();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancelar solicitud'),
              ),
          ],
        ),
      ),
    );
  }

  static const int _maxEspera = 180;

  Widget _construirIconoEstado(EstadoProrroga estado) {
    final (Color color, IconData icono) = switch (estado) {
      EstadoProrroga.esperando  => (AppColors.coralPrimario, Icons.hourglass_empty_rounded),
      EstadoProrroga.aprobada   => (AppColors.exitoVerde, Icons.check_circle_rounded),
      EstadoProrroga.rechazada  => (AppColors.coralAccion, Icons.cancel_rounded),
      EstadoProrroga.timeout    => (AppColors.encabezadoOscuro, Icons.timer_off_rounded),
      _                         => (AppColors.encabezadoOscuro, Icons.info_rounded),
    };
    return Container(
      width: 88, height: 88,
      decoration: BoxDecoration(
        color: color.withOpacity(.1), shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icono, color: color, size: 44),
    );
  }

  String _tituloEstado(EstadoProrroga estado) => switch (estado) {
    EstadoProrroga.esperando => 'Esperando respuesta',
    EstadoProrroga.aprobada  => '¡Prórroga aprobada!',
    EstadoProrroga.rechazada => 'Prórroga rechazada',
    EstadoProrroga.timeout   => 'Sin respuesta',
    _                        => 'Procesando...',
  };

  String _descripcionEstado(EstadoProrroga estado) => switch (estado) {
    EstadoProrroga.esperando =>
      'La solicitud fue enviada al autorizador.\nEspera hasta 3 minutos para recibir respuesta.',
    EstadoProrroga.aprobada  =>
      'El tiempo fue extendido. Vuelva a escanear el código QR para registrar el acceso.',
    EstadoProrroga.rechazada =>
      'El autorizador rechazó la solicitud. El visitante no puede acceder en este momento.',
    EstadoProrroga.timeout   =>
      'No se recibió respuesta en el tiempo máximo. El vigilante puede reintentar o denegar el acceso.',
    _                        => '',
  };
}

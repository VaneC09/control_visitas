// =============================================================================
// Archivo    : resultado_escaneo_view.dart
// Módulo     : features/vigilante/presentation/views
// Descripción: Pantalla 3 — Resultado del escaneo QR.
//              Muestra estado (válido, vencido, exclusión, etc.) con
//              información del visitante y acciones disponibles.
//              Basado en las imágenes de referencia del brief.
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
import '../../data/models/resultado_escaneo_model.dart';
import 'espera_prorroga_view.dart';
import 'home_vigilante_view.dart';

/// Pantalla de resultado de escaneo QR.
class ResultadoEscaneoView extends StatelessWidget {
  const ResultadoEscaneoView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm       = context.watch<VigilanteViewModel>();
    final resultado = vm.resultadoEscaneo;

    if (resultado == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.superficie0,
      appBar: AppBar(
        backgroundColor: _colorAppBar(resultado.estado),
        foregroundColor: AppColors.superficie0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resultado de Escaneo',
                style: TextStyle(color: AppColors.superficie0)),
            Text(resultado.codigoQr.isNotEmpty
                    ? resultado.codigoQr : 'Sin código',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            vm.limpiarEscaneo();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HomeVigilanteView()));
          },
        ),
      ),

      bottomNavigationBar: _construirBarraInferior(context, resultado, vm),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            // Banner de estado principal
            _BannerEstadoWidget(resultado: resultado),

            const SizedBox(height: AppSpacing.xs),

            // Información del visitante
            if (resultado.nombreVisitante.isNotEmpty)
              _SeccionWidget(
                icono: Icons.person_rounded,
                tituloColor: AppColors.navyProfundo,
                hijo: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.sutilCalido, shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.coralPrimario, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(resultado.nombreVisitante,
                        style: const TextStyle(fontWeight: FontWeight.w600,
                            color: AppColors.navyProfundo, fontSize: 15)),
                    const Text('Visitante',
                        style: TextStyle(color: AppColors.encabezadoOscuro,
                            fontSize: 12)),
                  ]),
                ]),
              ),

            const SizedBox(height: AppSpacing.xs),

            // Destino
            if (resultado.nombreAnfitrion.isNotEmpty)
              _SeccionWidget(
                icono: Icons.business_rounded,
                titulo: 'Destino',
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FilaWidget('Persona a visitar', resultado.nombreAnfitrion),
                    _FilaWidget('Departamento', resultado.departamento),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.xs),

            // Horario autorizado
            if (resultado.fechaVisita.isNotEmpty)
              _SeccionWidget(
                icono: Icons.schedule_rounded,
                titulo: 'Horario Autorizado',
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha',
                              style: TextStyle(fontSize: 11,
                                  color: AppColors.encabezadoOscuro)),
                          Row(children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 13, color: AppColors.encabezadoOscuro),
                            const SizedBox(width: 4),
                            Text(resultado.fechaVisita,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 13)),
                          ]),
                        ],
                      )),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hora',
                              style: TextStyle(fontSize: 11,
                                  color: AppColors.encabezadoOscuro)),
                          Row(children: [
                            const Icon(Icons.access_time_rounded,
                                size: 13, color: AppColors.encabezadoOscuro),
                            const SizedBox(width: 4),
                            Text(resultado.horaVisita,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 13)),
                          ]),
                        ],
                      )),
                    ]),

                    const SizedBox(height: 8),

                    // Indicador de rango horario (solo para entradas válidas)
                    if (resultado.estado == EstadoEscaneo.validoEntrada)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.exitoVerde),
                        ),
                        child: Row(children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.exitoVerde, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Horario dentro del rango permitido\n'
                              'Llegada: ${resultado.horaActual.length >= 16 ? resultado.horaActual.substring(11, 16) : ''} '
                              '• Programado: ${resultado.horaVisita}',
                              style: const TextStyle(
                                  color: AppColors.exitoVerde, fontSize: 11),
                            ),
                          ),
                        ]),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Barra de botones inferior
  // ---------------------------------------------------------------------------

  Widget? _construirBarraInferior(BuildContext context,
      ResultadoEscaneoModel resultado, VigilanteViewModel vm) {

    if (resultado.estado == EstadoEscaneo.validoEntrada) {
      return _BarraAccionesWidget(
        botonPrimario: _BotonAccion(
          texto: 'Registrar Entrada',
          icono: Icons.login_rounded,
          color: AppColors.exitoVerde,
          onTap: () {
            AppLogger.accionUsuario('Entrada registrada',
                contexto: {'id': resultado.idQr});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✓ Entrada registrada'),
                  backgroundColor: AppColors.exitoVerde,
                  behavior: SnackBarBehavior.floating),
            );
            vm.limpiarEscaneo();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HomeVigilanteView()));
          },
        ),
        botonSecundario: _BotonAccion(
          texto: 'Registrar Salida',
          icono: Icons.logout_rounded,
          color: AppColors.encabezadoOscuro,
          onTap: null, // Deshabilitado si no hay entrada previa
        ),
      );
    }

    if (resultado.estado == EstadoEscaneo.validoSalida) {
      return _BarraAccionesWidget(
        botonPrimario: _BotonAccion(
          texto: 'Registrar Salida',
          icono: Icons.logout_rounded,
          color: AppColors.encabezadoOscuro,
          onTap: () {
            AppLogger.accionUsuario('Salida registrada',
                contexto: {'id': resultado.idQr});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✓ Salida registrada'),
                  backgroundColor: AppColors.encabezadoOscuro,
                  behavior: SnackBarBehavior.floating),
            );
            vm.limpiarEscaneo();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HomeVigilanteView()));
          },
        ),
        botonSecundario: _BotonAccion(
          texto: 'Registrar Entrada',
          icono: Icons.login_rounded,
          color: AppColors.exitoVerde,
          onTap: null, // Deshabilitado — ya tiene entrada
        ),
      );
    }

    if (resultado.estado == EstadoEscaneo.vencido && resultado.permiteProrroga) {
      return Container(
        padding: EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.sm,
            AppSpacing.xs + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppColors.superficie0,
          border: Border(top: BorderSide(color: AppColors.superficie1, width: 0.5)),
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            AppLogger.accionUsuario('Prórroga solicitada');
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const EsperaProrrorgaView()));
          },
          icon: const Icon(Icons.more_time_rounded),
          label: const Text('Solicitar Prórroga'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coralPrimario,
            foregroundColor: AppColors.superficie0,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return null;
  }

  Color _colorAppBar(EstadoEscaneo estado) => switch (estado) {
    EstadoEscaneo.validoEntrada  => AppColors.exitoVerde,
    EstadoEscaneo.validoSalida   => AppColors.encabezadoOscuro,
    EstadoEscaneo.vencido        => AppColors.coralPrimario,
    EstadoEscaneo.enListaExclusion => AppColors.coralAccion,
    _                            => AppColors.navyProfundo,
  };
}

// =============================================================================
// Banner de estado principal
// =============================================================================

class _BannerEstadoWidget extends StatelessWidget {
  final ResultadoEscaneoModel resultado;
  const _BannerEstadoWidget({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final (Color fondo, Color texto, IconData icono, String etiqueta) =
        switch (resultado.estado) {
      EstadoEscaneo.validoEntrada  => (
        const Color(0xFFD1FAE5), AppColors.exitoVerde,
        Icons.check_circle_rounded, 'Código Válido'),
      EstadoEscaneo.validoSalida   => (
        const Color(0xFFDFEEFF), AppColors.encabezadoOscuro,
        Icons.check_circle_rounded, 'Registrar Salida'),
      EstadoEscaneo.vencido        => (
        AppColors.sutilCalido, AppColors.coralAccion,
        Icons.timer_off_rounded, 'Código Vencido'),
      EstadoEscaneo.enListaExclusion => (
        const Color(0xFFFEE2E2), AppColors.coralAccion,
        Icons.block_rounded, 'Acceso Denegado'),
      EstadoEscaneo.noEncontrado   => (
        AppColors.superficie1, AppColors.encabezadoOscuro,
        Icons.search_off_rounded, 'Código No Encontrado'),
      EstadoEscaneo.yaUtilizado    => (
        AppColors.superficie1, AppColors.encabezadoOscuro,
        Icons.check_circle_outline_rounded, 'Ya Utilizado'),
      _                            => (
        AppColors.superficie1, AppColors.encabezadoOscuro,
        Icons.help_outline_rounded, 'Estado Desconocido'),
    };

    final hora = resultado.horaActual.length >= 16
        ? resultado.horaActual.substring(11, 16) : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
        border: Border.all(color: texto.withOpacity(.3)),
      ),
      child: Column(children: [
        Icon(icono, color: texto, size: 48),
        const SizedBox(height: 8),
        Text(etiqueta,
            style: TextStyle(color: texto, fontSize: 18, fontWeight: FontWeight.w600)),
        if (hora.isNotEmpty)
          Text('Hora de llegada: $hora',
              style: TextStyle(color: texto.withOpacity(.7), fontSize: 12)),
      ]),
    );
  }
}

// =============================================================================
// Sección con título e ícono
// =============================================================================

class _SeccionWidget extends StatelessWidget {
  final IconData icono;
  final String?  titulo;
  final Color    tituloColor;
  final Widget   hijo;

  const _SeccionWidget({
    required this.icono, this.titulo,
    this.tituloColor = AppColors.navyProfundo,
    required this.hijo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.superficie0,
        border: Border.all(color: AppColors.superficie1, width: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != null) ...[
            Row(children: [
              Icon(icono, size: 16, color: AppColors.encabezadoOscuro),
              const SizedBox(width: 6),
              Text(titulo!, style: TextStyle(fontWeight: FontWeight.w600,
                  color: tituloColor, fontSize: 14)),
            ]),
            const SizedBox(height: AppSpacing.xs),
          ],
          hijo,
        ],
      ),
    );
  }
}

class _FilaWidget extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _FilaWidget(this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(etiqueta,
          style: const TextStyle(fontSize: 11, color: AppColors.encabezadoOscuro)),
      Text(valor,
          style: const TextStyle(fontSize: 13, color: AppColors.navyProfundo,
              fontWeight: FontWeight.w500)),
    ]),
  );
}

// =============================================================================
// Barra de dos botones inferior
// =============================================================================

class _BotonAccion {
  final String    texto;
  final IconData  icono;
  final Color     color;
  final VoidCallback? onTap;
  _BotonAccion({required this.texto, required this.icono,
    required this.color, required this.onTap});
}

class _BarraAccionesWidget extends StatelessWidget {
  final _BotonAccion botonPrimario;
  final _BotonAccion botonSecundario;
  const _BarraAccionesWidget(
      {required this.botonPrimario, required this.botonSecundario});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.sm,
          AppSpacing.xs + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.superficie0,
        border: Border(top: BorderSide(color: AppColors.superficie1, width: 0.5)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Botón primario (activo)
        ElevatedButton.icon(
          onPressed: botonPrimario.onTap,
          icon: Icon(botonPrimario.icono, size: 18),
          label: Text(botonPrimario.texto),
          style: ElevatedButton.styleFrom(
            backgroundColor: botonPrimario.color,
            foregroundColor: AppColors.superficie0,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 6),
        // Botón secundario (deshabilitado si onTap == null)
        OutlinedButton.icon(
          onPressed: botonSecundario.onTap,
          icon: Icon(botonSecundario.icono, size: 18),
          label: Text(botonSecundario.texto),
          style: OutlinedButton.styleFrom(
            foregroundColor: botonSecundario.onTap != null
                ? botonSecundario.color : AppColors.superficie1,
            side: BorderSide(
              color: botonSecundario.onTap != null
                  ? botonSecundario.color : AppColors.superficie1,
            ),
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
    );
  }
}

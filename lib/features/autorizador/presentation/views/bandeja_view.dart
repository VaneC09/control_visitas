// =============================================================================
// Archivo    : bandeja_view.dart
// Módulo     : features/autorizador/presentation/views
// Descripción: Pantalla 2 — Bandeja de solicitudes pendientes.
//              Muestra lista filtrable, botones directos de acción y
//              acceso al detalle. Maneja los estados vacío, cargando y error.
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
import '../../bloc/bandeja_viewmodel.dart';
import '../../data/models/solicitud_model.dart';
import '../widgets/dialogo_confirmacion_widget.dart';
import '../widgets/tarjeta_solicitud_widget.dart';

/// Pantalla principal del autorizador — bandeja de solicitudes.
class BandejaView extends StatefulWidget {
  const BandejaView({super.key});

  @override
  State<BandejaView> createState() => _BandejaViewState();
}

class _BandejaViewState extends State<BandejaView> {
  final _busquedaCtrl = TextEditingController();

  // Etiquetas de filtros de estado
  static const _filtros = ['Todos', 'Pendientes', 'Aprobados', 'Rechazados'];

  @override
  void initState() {
    super.initState();
    // Cargar solicitudes al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BandejaViewModel>().cargarSolicitudes();
      AppLogger.navegacion('BandejaView');
    });
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  /// Muestra el diálogo de confirmación y ejecuta la aprobación.
  Future<void> _confirmarAprobar(
      BuildContext context, SolicitudModel solicitud) async {
    AppLogger.accionUsuario('Diálogo aprobar abierto',
        contexto: {'id': solicitud.idSolicitud});

    final confirmo = await DialogoConfirmacionWidget.mostrar(
      context: context,
      tipo: TipoAccionDialogo.aprobar,
      nombreSolicitante: solicitud.nombreSolicitante,
    );

    if (confirmo != true || !mounted) return;

    await context.read<BandejaViewModel>().aprobar(
      idSolicitud: solicitud.idSolicitud,
      onExito: () => _mostrarSnackBar(
        context,
        '✓ Solicitud aprobada correctamente',
        AppColors.exitoVerde,
      ),
      onError: (msg) => _mostrarSnackBar(context, msg, AppColors.coralAccion),
    );
  }

  /// Muestra el diálogo de confirmación y ejecuta el rechazo.
  Future<void> _confirmarRechazar(
      BuildContext context, SolicitudModel solicitud) async {
    AppLogger.accionUsuario('Diálogo rechazar abierto',
        contexto: {'id': solicitud.idSolicitud});

    final confirmo = await DialogoConfirmacionWidget.mostrar(
      context: context,
      tipo: TipoAccionDialogo.rechazar,
      nombreSolicitante: solicitud.nombreSolicitante,
    );

    if (confirmo != true || !mounted) return;

    await context.read<BandejaViewModel>().rechazar(
      idSolicitud: solicitud.idSolicitud,
      onExito: () => _mostrarSnackBar(
        context,
        'Solicitud rechazada',
        AppColors.coralAccion,
      ),
      onError: (msg) => _mostrarSnackBar(context, msg, AppColors.coralAccion),
    );
  }

  /// Muestra un SnackBar con mensaje y color semántico.
  void _mostrarSnackBar(BuildContext context, String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<BandejaViewModel>();
    final auth = context.watch<AuthViewModel>();
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.superficie0,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bandeja de solicitudes'),
            Text(
              'Autorizador · ${vm.solicitudesFiltradas.length} resultado(s)',
              style: tema.textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          // Botón de notificaciones
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () {
              AppLogger.navegacion(AppRoutes.notificaciones);
              Navigator.pushNamed(context, AppRoutes.notificaciones);
            },
          ),
          // Menú de opciones
          PopupMenuButton<String>(
            onSelected: (valor) async {
              if (valor == 'cerrar') {
                await auth.logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.seleccionRol, (_) => false);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'usuario',
                enabled: false,
                child: Text(
                  auth.empleado?.nombreCompleto ?? '',
                  style: tema.textTheme.labelMedium,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'cerrar',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // -----------------------------------------------------------------
          // Barra de búsqueda
          // -----------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, 0),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: context.read<BandejaViewModel>().buscar,
              decoration: InputDecoration(
                hintText: 'Buscar por empleado, visitante…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: vm.textoBusqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _busquedaCtrl.clear();
                          context.read<BandejaViewModel>().buscar('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // -----------------------------------------------------------------
          // Filtros de estado (chips horizontales)
          // -----------------------------------------------------------------
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 6),
              itemCount: _filtros.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final activo = vm.filtroActivo == i;
                return GestureDetector(
                  onTap: () => context.read<BandejaViewModel>().cambiarFiltro(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: activo ? AppColors.coralPrimario : AppColors.superficie0,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: activo
                            ? AppColors.coralPrimario
                            : AppColors.superficie1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _filtros[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: activo
                              ? AppColors.superficie0
                              : AppColors.encabezadoOscuro,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // -----------------------------------------------------------------
          // Contenido principal según estado
          // -----------------------------------------------------------------
          Expanded(child: _construirContenido(context, vm)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Construir contenido según estado del ViewModel
  // ---------------------------------------------------------------------------

  Widget _construirContenido(BuildContext context, BandejaViewModel vm) {
    switch (vm.estado) {
      // Estado: Cargando
      case EstadoBandeja.cargando:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.coralPrimario),
        );

      // Estado: Error
      case EstadoBandeja.error:
        return _PantallaErrorWidget(
          mensaje: vm.mensajeError,
          onReintentar: () => context.read<BandejaViewModel>().cargarSolicitudes(),
        );

      // Estado: Sin solicitudes
      case EstadoBandeja.vacio:
        return const _PantallaVaciaWidget();

      // Estado: Con datos / procesando
      case EstadoBandeja.conDatos:
      case EstadoBandeja.procesando:
        return RefreshIndicator(
          color: AppColors.coralPrimario,
          onRefresh: () => context.read<BandejaViewModel>().cargarSolicitudes(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.sm),
            itemCount: vm.solicitudesFiltradas.length,
            itemBuilder: (ctx, i) {
              final solicitud = vm.solicitudesFiltradas[i];
              final procesando = vm.idProcesando == solicitud.idSolicitud;

              return TarjetaSolicitudWidget(
                solicitud: solicitud,
                estaProcesando: procesando,
                onAutorizar: () => _confirmarAprobar(ctx, solicitud),
                onRechazar:  () => _confirmarRechazar(ctx, solicitud),
                onVerDetalle: () {
                  AppLogger.navegacion(
                      '${AppRoutes.detalleSolicitud}/${solicitud.idSolicitud}');
                  Navigator.pushNamed(
                    ctx,
                    AppRoutes.detalleSolicitud,
                    arguments: solicitud,
                  );
                },
              );
            },
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// =============================================================================
// Pantalla vacía
// =============================================================================

class _PantallaVaciaWidget extends StatelessWidget {
  const _PantallaVaciaWidget();

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
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.superficie1,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 36,
                color: AppColors.encabezadoOscuro,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Sin solicitudes pendientes',
                style: tema.textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'No hay solicitudes que requieran tu atención en este momento.',
              style: tema.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Pantalla de error
// =============================================================================

class _PantallaErrorWidget extends StatelessWidget {
  final String       mensaje;
  final VoidCallback onReintentar;

  const _PantallaErrorWidget({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 52, color: AppColors.encabezadoOscuro),
            const SizedBox(height: AppSpacing.sm),
            Text('Sin conexión', style: tema.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(mensaje,
                style: tema.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

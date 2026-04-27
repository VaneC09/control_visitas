// =============================================================================
// Archivo: dashboard_solicitante_view.dart
// Módulo: solicitante/presentation/views
// Descripción: Vista principal del módulo Solicitante (Dashboard).
// Autor: OMEGA Solutions
// Versión: 1.0
// Fecha: 2026-04-26
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_routes.dart';
import '../../bloc/solicitante_provider.dart';
import '../widgets/tarjeta_solicitud_widget.dart';
import 'nueva_solicitud_view.dart';
import 'detalle_solicitud_solicitante_view.dart';

class DashboardSolicitanteView extends StatelessWidget {
  const DashboardSolicitanteView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SolicitanteProvider(),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolicitanteProvider>().cargarSolicitudes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE07A5F),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Empleado',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _NotificacionesSolicitanteView(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.seleccionRol,
              (_) => false,
            ),
          ),
        ],
      ),
      body: Consumer<SolicitanteProvider>(
        builder: (context, provider, _) {
          if (provider.estadoLista == EstadoCarga.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.estadoLista == EstadoCarga.error) {
            return _buildError(provider);
          }

          return RefreshIndicator(
            onRefresh: () => provider.cargarSolicitudes(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.proximasVisitas.isNotEmpty) ...[
                    const Text(
                      'Próximas visitas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...provider.proximasVisitas.map(
                      (s) => TarjetaSolicitudWidget(
                        solicitud: s,
                        onTap: () => _abrirDetalle(context, s.idSolicitud!),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Todas las solicitudes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (provider.todasSolicitudes.isEmpty)
                    _buildVacio()
                  else
                    ...provider.todasSolicitudes.map(
                      (s) => TarjetaSolicitudWidget(
                        solicitud: s,
                        onTap: s.idSolicitud != null
                            ? () => _abrirDetalle(context, s.idSolicitud!)
                            : null,
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirNuevaSolicitud(context),
        backgroundColor: const Color(0xFFE07A5F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildError(SolicitanteProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            provider.errorLista,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.cargarSolicitudes(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE07A5F),
            ),
            child: const Text('Reintentar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildVacio() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No tienes solicitudes aún.\nPresiona + para crear una.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _abrirNuevaSolicitud(BuildContext context) {
    context.read<SolicitanteProvider>().iniciarNuevaSolicitud();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<SolicitanteProvider>(),
          child: const NuevaSolicitudView(),
        ),
      ),
    );
  }

  void _abrirDetalle(BuildContext context, int idSolicitud) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<SolicitanteProvider>(),
          child: DetalleSolicitudSolicitanteView(idSolicitud: idSolicitud),
        ),
      ),
    );
  }
}

// =============================================================================
// Pantalla de notificaciones del solicitante
// =============================================================================
class _NotificacionesSolicitanteView extends StatelessWidget {
  const _NotificacionesSolicitanteView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE07A5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No tienes notificaciones.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
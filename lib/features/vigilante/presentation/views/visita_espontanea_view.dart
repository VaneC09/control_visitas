// =============================================================================
// Archivo    : visita_espontanea_view.dart
// Módulo     : features/vigilante/presentation/views
// Descripción: Pantalla 5 — Registro rápido de visita sin cita (walk-in).
//              Formulario: nombre (opcional), correo (obligatorio),
//              departamento destino (obligatorio).
//              Basado en la imagen de referencia "Registro Rápido".
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

/// Lista de departamentos de prueba (cargar desde API en producción).
const List<Map<String, dynamic>> _departamentos = [
  {'id': 1, 'nombre': 'Tecnologías de la Información'},
  {'id': 2, 'nombre': 'Recursos Humanos'},
  {'id': 3, 'nombre': 'Dirección General'},
  {'id': 4, 'nombre': 'Finanzas'},
  {'id': 5, 'nombre': 'Alberca'},
  {'id': 6, 'nombre': 'Control Escolar'},
  {'id': 7, 'nombre': 'Recepción'},
];

/// Pantalla de registro rápido de visita espontánea.
class VisitaEspontaneaView extends StatefulWidget {
  const VisitaEspontaneaView({super.key});

  @override
  State<VisitaEspontaneaView> createState() => _VisitaEspontaneaViewState();
}

class _VisitaEspontaneaViewState extends State<VisitaEspontaneaView> {
  final _formKey     = GlobalKey<FormState>();
  final _nombreCtrl  = TextEditingController();
  final _correoCtrl  = TextEditingController();
  int?  _idDeptSeleccionado;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _generarQR(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_idDeptSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un departamento destino'),
            backgroundColor: AppColors.coralAccion,
            behavior: SnackBarBehavior.floating),
      );
      return;
    }

    AppLogger.accionUsuario('Generar QR espontáneo',
        contexto: {'correo': _correoCtrl.text});

    await context.read<VigilanteViewModel>().registrarEspontanea(
      nombre:          _nombreCtrl.text.trim(),
      correo:          _correoCtrl.text.trim(),
      idDepartamento:  _idDeptSeleccionado!,
      onExito: () {
        if (!mounted) return;
        final resultado = context.read<VigilanteViewModel>().resultadoEspontanea;
        _mostrarResultado(context, resultado);
      },
    );
  }

  void _mostrarResultado(BuildContext context, Map<String, dynamic>? resultado) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5), shape: BoxShape.circle),
              child: const Icon(Icons.qr_code_rounded,
                  color: AppColors.exitoVerde, size: 32),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text('QR Generado',
                style: TextStyle(fontWeight: FontWeight.w600,
                    fontSize: 16, color: AppColors.navyProfundo)),
            const SizedBox(height: 6),
            Text(resultado?['codigoQr'] ?? '',
                style: const TextStyle(fontFamily: 'monospace',
                    fontSize: 14, color: AppColors.encabezadoOscuro)),
            const SizedBox(height: 6),
            Text(resultado?['mensaje'] ?? '',
                style: const TextStyle(fontSize: 12,
                    color: AppColors.encabezadoOscuro),
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              context.read<VigilanteViewModel>().limpiarEspontanea();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const HomeVigilanteView()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.exitoVerde,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Registrar Entrada',
                style: TextStyle(color: AppColors.superficie0)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm      = context.watch<VigilanteViewModel>();
    final tema    = Theme.of(context);
    final cargando = vm.estadoEspontanea == EstadoVigilante.cargando;

    return Scaffold(
      backgroundColor: AppColors.superficie0,
      appBar: AppBar(
        backgroundColor: AppColors.exitoVerde,
        foregroundColor: AppColors.superficie0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registro Rápido',
                style: TextStyle(color: AppColors.superficie0)),
            Text('Visita sin cita previa',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.xs, AppSpacing.sm,
          AppSpacing.xs + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.superficie0,
          border: Border(top: BorderSide(color: AppColors.superficie1, width: 0.5)),
        ),
        child: ElevatedButton.icon(
          onPressed: cargando ? null : () => _generarQR(context),
          icon: cargando
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.superficie0))
              : const Icon(Icons.qr_code_2_rounded, size: 20),
          label: Text(cargando ? 'Generando QR...' : 'Generar QR y Registrar Entrada'),
          style: ElevatedButton.styleFrom(
            backgroundColor: cargando
                ? AppColors.encabezadoOscuro : AppColors.exitoVerde,
            foregroundColor: AppColors.superficie0,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner informativo — acceso inmediato
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.azulNube,
                  borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
                  border: Border.all(color: AppColors.azulCielo, width: 0.5),
                ),
                child: Row(children: [
                  const Icon(Icons.qr_code_2_rounded,
                      color: AppColors.encabezadoOscuro, size: 32),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Acceso inmediato',
                            style: tema.textTheme.bodyMedium?.copyWith(
                                color: AppColors.encabezadoOscuro,
                                fontWeight: FontWeight.w600)),
                        Text(
                          'Este registro genera un QR temporal para '
                          'visitantes sin cita programada',
                          style: tema.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Campo: nombre (opcional)
              Row(children: [
                const Icon(Icons.person_outline_rounded,
                    size: 16, color: AppColors.encabezadoOscuro),
                const SizedBox(width: 6),
                Text('Nombre del visitante ',
                    style: tema.textTheme.bodyMedium?.copyWith(
                        color: AppColors.navyProfundo)),
                const Text('(opcional)',
                    style: TextStyle(fontSize: 11, color: AppColors.exitoVerde)),
              ]),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nombreCtrl,
                textInputAction: TextInputAction.next,
                enabled: !cargando,
                decoration: const InputDecoration(
                  hintText: 'Ej: Juan Pérez García',
                ),
              ),
              const Text(
                'Si no proporciona nombre, se registrará como "Visitante"',
                style: TextStyle(fontSize: 11, color: AppColors.encabezadoOscuro),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Campo: correo (obligatorio)
              Row(children: [
                const Icon(Icons.email_outlined,
                    size: 16, color: AppColors.encabezadoOscuro),
                const SizedBox(width: 6),
                Text('Correo electrónico ',
                    style: tema.textTheme.bodyMedium?.copyWith(
                        color: AppColors.navyProfundo)),
                const Text('(obligatorio)',
                    style: TextStyle(fontSize: 11, color: AppColors.coralAccion)),
              ]),
              const SizedBox(height: 6),
              TextFormField(
                controller: _correoCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !cargando,
                decoration: const InputDecoration(hintText: 'ejemplo@correo.com'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'El correo es obligatorio';
                  if (!v.contains('@') || !v.contains('.')) return 'Correo inválido';
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              // Campo: departamento destino (obligatorio)
              Row(children: [
                const Icon(Icons.business_outlined,
                    size: 16, color: AppColors.encabezadoOscuro),
                const SizedBox(width: 6),
                Text('Departamento destino ',
                    style: tema.textTheme.bodyMedium?.copyWith(
                        color: AppColors.navyProfundo)),
                const Text('(obligatorio)',
                    style: TextStyle(fontSize: 11, color: AppColors.coralAccion)),
              ]),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _idDeptSeleccionado,
                hint: const Text('Selecciona un departamento'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.superficie0,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.bordeInput),
                  ),
                ),
                items: _departamentos.map((d) => DropdownMenuItem<int>(
                  value: d['id'] as int,
                  child: Text(d['nombre'] as String,
                      overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: cargando ? null : (v) =>
                    setState(() => _idDeptSeleccionado = v),
              ),

              // Nota sobre el QR temporal
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.sutilCalido,
                  borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Sobre el código QR temporal',
                        style: TextStyle(fontWeight: FontWeight.w600,
                            color: AppColors.navyProfundo, fontSize: 13)),
                    SizedBox(height: 6),
                    Text('• Válido solo por el día actual',
                        style: TextStyle(fontSize: 12, color: AppColors.azulAcero)),
                    Text('• Se enviará al correo proporcionado',
                        style: TextStyle(fontSize: 12, color: AppColors.azulAcero)),
                    Text('• El visitante puede ingresar de inmediato',
                        style: TextStyle(fontSize: 12, color: AppColors.azulAcero)),
                    Text('• Requiere registro de salida',
                        style: TextStyle(fontSize: 12, color: AppColors.azulAcero)),
                  ],
                ),
              ),

              // Sugerencia si no conoce el destino
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.azulNube,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.azulCielo, width: 0.5),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.encabezadoOscuro),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Si el visitante no conoce el departamento, '
                      'sugerir preguntar en Recepción.',
                      style: TextStyle(fontSize: 11,
                          color: AppColors.encabezadoOscuro),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

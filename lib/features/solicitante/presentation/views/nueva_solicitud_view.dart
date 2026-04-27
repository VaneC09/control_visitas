// =============================================================================
// Archivo: nueva_solicitud_view.dart
// Módulo: solicitante/presentation/views
// Descripción: Wizard de 3 pasos para crear una nueva solicitud de visita.
// Autor: OMEGA Solutions
// Versión: 1.0
// Fecha: 2026-04-26
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/solicitante_provider.dart';
import '../../data/models/solicitud_model.dart';
import 'dashboard_solicitante_view.dart';


/// Vista wizard de nueva solicitud (3 pasos).
class NuevaSolicitudView extends StatefulWidget {
  const NuevaSolicitudView({super.key});

  @override
  State<NuevaSolicitudView> createState() => _NuevaSolicitudViewState();
}

class _NuevaSolicitudViewState extends State<NuevaSolicitudView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolicitanteProvider>().cargarCatalogos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SolicitanteProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFE07A5F),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (provider.pasoActual > 0) {
                  provider.retrocederPaso();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nueva Solicitud',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
                Text(
                  'Paso ${provider.pasoActual + 1} de 3',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              _BarraProgreso(pasoActual: provider.pasoActual),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: _buildPaso(provider),
                ),
              ),
              _buildBotonesNavegacion(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaso(SolicitanteProvider provider) {
    switch (provider.pasoActual) {
      case 0:
        return _Paso1TipoVisita(provider: provider);
      case 1:
        return _Paso2DatosVisitantes(provider: provider);
      case 2:
        return _Paso3FechaHora(provider: provider);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBotonesNavegacion(
      BuildContext context, SolicitanteProvider provider) {
    final esUltimoPaso = provider.pasoActual == 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (provider.pasoActual > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: provider.retrocederPaso,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFE07A5F)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Anterior',
                  style: TextStyle(color: Color(0xFFE07A5F)),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: provider.pasoActual > 0 ? 2 : 1,
            child: ElevatedButton(
              onPressed: provider.enviando
                  ? null
                  : () => _avanzarOEnviar(context, provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE07A5F),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: provider.enviando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      esUltimoPaso ? 'Enviar Solicitud' : 'Siguiente',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _avanzarOEnviar(
      BuildContext context, SolicitanteProvider provider) async {
    if (provider.pasoActual == 2) {
      if (provider.fechaVisita == null) {
        _mostrarError(context, 'Seleccione la fecha de visita.');
        return;
      }
      if (provider.horaVisita == null) {
        _mostrarError(context, 'Seleccione la hora estimada.');
        return;
      }
      await provider.enviarSolicitud();
      if (!mounted) return;
      if (provider.creacionExitosa) {
        _mostrarExito(context);
      } else if (provider.errorCrear.isNotEmpty) {
        _mostrarError(context, provider.errorCrear);
      }
    } else {
      if (!_validarPasoActual(context, provider)) return;
      provider.avanzarPaso();
    }
  }

  bool _validarPasoActual(
      BuildContext context, SolicitanteProvider provider) {
    if (provider.pasoActual == 1) {
      for (final v in provider.visitantes) {
        if (v.nombre.trim().isEmpty ||
            v.apellidos.trim().isEmpty ||
            v.correoPersonal.trim().isEmpty) {
          _mostrarError(
              context, 'Complete todos los datos de los visitantes.');
          return false;
        }
        if (!v.correoPersonal.contains('@')) {
          _mostrarError(
              context, 'Ingrese un correo electrónico válido.');
          return false;
        }
      }
    }
    return true;
  }

  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarExito(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: Color(0xFF2E7D32), size: 64),
            const SizedBox(height: 16),
            const Text(
              '¡Solicitud enviada!',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu solicitud fue registrada correctamente.\nEspera la autorización.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
            Navigator.of(context).pop(); // cierra dialog
            Navigator.of(context).pop();
          },
            child: const Text('Aceptar',
                style: TextStyle(color: Color(0xFFE07A5F))),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Paso 1: Tipo de visita
// =============================================================================
class _Paso1TipoVisita extends StatelessWidget {
  final SolicitanteProvider provider;

  const _Paso1TipoVisita({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de visita',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _OpcionTipoVisita(
            titulo: 'Individual',
            subtitulo: 'Un solo visitante',
            icono: Icons.person_outline,
            seleccionado: provider.tipoVisita == 'individual',
            onTap: () => provider.setTipoVisita('individual'),
          ),
          const SizedBox(height: 12),
          _OpcionTipoVisita(
            titulo: 'Grupo',
            subtitulo: 'Múltiples visitantes',
            icono: Icons.group_outlined,
            seleccionado: provider.tipoVisita == 'grupal',
            onTap: () => provider.setTipoVisita('grupal'),
          ),
        ],
      ),
    );
  }
}

class _OpcionTipoVisita extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback onTap;

  const _OpcionTipoVisita({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: seleccionado
              ? const Color(0xFFE07A5F).withValues(alpha: 0.08)
              : Colors.white,
          border: Border.all(
            color: seleccionado
                ? const Color(0xFFE07A5F)
                : Colors.grey.shade300,
            width: seleccionado ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: seleccionado
                    ? const Color(0xFFE07A5F).withValues(alpha: 0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icono,
                color: seleccionado
                    ? const Color(0xFFE07A5F)
                    : Colors.grey[500],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: seleccionado
                          ? const Color(0xFFE07A5F)
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: seleccionado ? true : null,
              onChanged: (_) => onTap(),
              activeColor: const Color(0xFFE07A5F),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Paso 2: Datos de visitantes
// =============================================================================
class _Paso2DatosVisitantes extends StatelessWidget {
  final SolicitanteProvider provider;

  const _Paso2DatosVisitantes({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.tipoVisita == 'individual'
                ? 'Datos del visitante'
                : 'Datos de los visitantes',
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            provider.visitantes.length,
            (index) => _FormVisitante(
              index: index,
              visitante: provider.visitantes[index],
              esGrupal: provider.tipoVisita == 'grupal',
              onActualizar: (v) => provider.actualizarVisitante(index, v),
              onEliminar: provider.visitantes.length > 1
                  ? () => provider.eliminarVisitante(index)
                  : null,
            ),
          ),
          if (provider.tipoVisita == 'grupal') ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: provider.agregarVisitante,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE07A5F),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xFFE07A5F), size: 18),
                    SizedBox(width: 6),
                    Text(
                      '+ Agregar visitante',
                      style: TextStyle(
                        color: Color(0xFFE07A5F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 16, color: Color(0xFFE07A5F)),
              SizedBox(width: 6),
              Text('Motivo de visita',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: provider.motivoVisita,
            decoration: InputDecoration(
              hintText: 'Describe el motivo de la visita',
              filled: true,
              fillColor: const Color(0xFFFAEFED),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
            onChanged: provider.setMotivoVisita,
          ),
        ],
      ),
    );
  }
}

class _FormVisitante extends StatefulWidget {
  final int index;
  final VisitanteModel visitante;
  final bool esGrupal;
  final Function(VisitanteModel) onActualizar;
  final VoidCallback? onEliminar;

  const _FormVisitante({
    required this.index,
    required this.visitante,
    required this.esGrupal,
    required this.onActualizar,
    this.onEliminar,
  });

  @override
  State<_FormVisitante> createState() => _FormVisitanteState();
}

class _FormVisitanteState extends State<_FormVisitante> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidosCtrl;
  late TextEditingController _correoCtrl;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.visitante.nombre);
    _apellidosCtrl =
        TextEditingController(text: widget.visitante.apellidos);
    _correoCtrl =
        TextEditingController(text: widget.visitante.correoPersonal);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  void _notificar() {
    widget.onActualizar(
      VisitanteModel(
        idVisitante: widget.visitante.idVisitante,
        nombre: _nombreCtrl.text,
        apellidos: _apellidosCtrl.text,
        correoPersonal: _correoCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.esGrupal)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Visitante ${widget.index + 1}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (widget.onEliminar != null)
                  IconButton(
                    onPressed: widget.onEliminar,
                    icon: const Icon(Icons.close,
                        size: 18, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          if (widget.esGrupal) const SizedBox(height: 12),
          TextFormField(
            controller: _nombreCtrl,
            decoration: _inputDecoration('Nombre'),
            onChanged: (_) => _notificar(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _apellidosCtrl,
            decoration: _inputDecoration('Apellidos'),
            onChanged: (_) => _notificar(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _correoCtrl,
            decoration: _inputDecoration('Correo electrónico'),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _notificar(),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: const Color(0xFFFAEFED),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

// =============================================================================
// Paso 3: Fecha y hora
// =============================================================================
class _Paso3FechaHora extends StatelessWidget {
  final SolicitanteProvider provider;

  const _Paso3FechaHora({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fecha y hora',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Fecha
          const Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: Color(0xFFE07A5F)),
              SizedBox(width: 6),
              Text('Fecha de visita',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _seleccionarFecha(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAEFED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    provider.fechaVisita != null
                        ? '${provider.fechaVisita!.day.toString().padLeft(2, '0')}/${provider.fechaVisita!.month.toString().padLeft(2, '0')}/${provider.fechaVisita!.year}'
                        : 'dd/mm/aaaa',
                    style: TextStyle(
                      color: provider.fechaVisita != null
                          ? Colors.black87
                          : Colors.grey[400],
                    ),
                  ),
                  Icon(Icons.calendar_month,
                      color: Colors.grey[400], size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Hora
          const Row(
            children: [
              Icon(Icons.access_time,
                  size: 16, color: Color(0xFFE07A5F)),
              SizedBox(width: 6),
              Text('Hora estimada',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _seleccionarHora(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAEFED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    provider.horaVisita != null
                        ? '${provider.horaVisita!.hour.toString().padLeft(2, '0')}:${provider.horaVisita!.minute.toString().padLeft(2, '0')}'
                        : '--:-- -----',
                    style: TextStyle(
                      color: provider.horaVisita != null
                          ? Colors.black87
                          : Colors.grey[400],
                    ),
                  ),
                  Icon(Icons.schedule, color: Colors.grey[400], size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tolerancia
          const Text(
            'Tolerancia de llegada',
            style:
                TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _BotonaTolerancia(
                label: '15 min',
                seleccionado: provider.toleranciaMinutos == 15,
                onTap: () => provider.setTolerancia(15),
              ),
              const SizedBox(width: 12),
              _BotonaTolerancia(
                label: '30 min',
                seleccionado: provider.toleranciaMinutos == 30,
                onTap: () => provider.setTolerancia(30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final hoy = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: provider.fechaVisita ?? hoy,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE07A5F),
          ),
        ),
        child: child!,
      ),
    );
    if (seleccionada != null) {
      provider.setFechaVisita(seleccionada);
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final seleccionada = await showTimePicker(
      context: context,
      initialTime: provider.horaVisita ??
          TimeOfDay(hour: DateTime.now().hour, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE07A5F),
          ),
        ),
        child: child!,
      ),
    );
    if (seleccionada != null) {
      provider.setHoraVisita(seleccionada);
    }
  }
}

// =============================================================================
// Widget: Botón de tolerancia
// =============================================================================
class _BotonaTolerancia extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _BotonaTolerancia({
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: seleccionado
                ? const Color(0xFFE07A5F).withValues(alpha: 0.08)
                : Colors.white,
            border: Border.all(
              color: seleccionado
                  ? const Color(0xFFE07A5F)
                  : Colors.grey.shade300,
              width: seleccionado ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: seleccionado
                  ? const Color(0xFFE07A5F)
                  : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Widget: Barra de progreso del wizard
// =============================================================================
class _BarraProgreso extends StatelessWidget {
  final int pasoActual;

  const _BarraProgreso({required this.pasoActual});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE07A5F),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: List.generate(3, (index) {
          final completado = index <= pasoActual;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
              decoration: BoxDecoration(
                color: completado
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
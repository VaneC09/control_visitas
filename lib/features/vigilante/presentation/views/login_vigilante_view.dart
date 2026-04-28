// =============================================================================
// Archivo    : login_vigilante_view.dart
// Módulo     : features/vigilante/presentation/views
// Descripción: Pantalla 0 — Login del vigilante con validación de
//              usuario, contraseña y número de teléfono del dispositivo.
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

/// Pantalla de autenticación del vigilante.
class LoginVigilanteView extends StatefulWidget {
  const LoginVigilanteView({super.key});

  @override
  State<LoginVigilanteView> createState() => _LoginVigilanteViewState();
}

class _LoginVigilanteViewState extends State<LoginVigilanteView> {
  final _formKey      = GlobalKey<FormState>();
  final _correoCtrl   = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _telCtrl      = TextEditingController();

  @override
  void dispose() {
    _correoCtrl.dispose(); _passCtrl.dispose(); _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    AppLogger.accionUsuario('Login vigilante presionado');

    await context.read<VigilanteViewModel>().login(
      correo:   _correoCtrl.text.trim(),
      contrasena: _passCtrl.text,
      telefono: _telCtrl.text.trim(),
      onExito: () {
        AppLogger.navegacion('HomeVigilanteView');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomeVigilanteView()));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<VigilanteViewModel>();
    final tema = Theme.of(context);
    final cargando = vm.estadoAuth == EstadoVigilante.cargando;

    return Scaffold(
      backgroundColor: AppColors.superficie0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),

                // Logo con color verde (tema vigilante)
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.exitoVerde,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.security_rounded,
                      color: AppColors.superficie0, size: 44),
                ),

                const SizedBox(height: AppSpacing.sm),
                Text('Control de Accesos', style: tema.textTheme.headlineLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text('Módulo Vigilante', style: tema.textTheme.bodyMedium,
                    textAlign: TextAlign.center),

                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Vigilante de Seguridad',
                    style: tema.textTheme.labelMedium?.copyWith(
                        color: AppColors.exitoVerde)),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Campo correo
                TextFormField(
                  controller: _correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !cargando,
                  decoration: const InputDecoration(
                    labelText: 'Usuario institucional',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Ingresa tu usuario institucional' : null,
                ),

                const SizedBox(height: AppSpacing.xs),

                // Campo contraseña
                TextFormField(
                  controller: _passCtrl,
                  obscureText: vm.ocultarContrasena,
                  textInputAction: TextInputAction.next,
                  enabled: !cargando,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(vm.ocultarContrasena
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                          color: AppColors.encabezadoOscuro),
                      onPressed: context.read<VigilanteViewModel>().alternarContrasena,
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Ingresa tu contraseña' : null,
                ),

                const SizedBox(height: AppSpacing.xs),

                // Campo número de teléfono (validación de dispositivo)
                TextFormField(
                  controller: _telCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  enabled: !cargando,
                  onFieldSubmitted: (_) => _iniciarSesion(context),
                  decoration: const InputDecoration(
                    labelText: 'Número de teléfono del dispositivo',
                    prefixIcon: Icon(Icons.phone_android_rounded),
                    hintText: '10 dígitos',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa el número de teléfono';
                    }
                    return null;
                  },
                ),

                // Mensaje informativo sobre la validación del dispositivo
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'El número debe coincidir con el registrado en el sistema.',
                    style: tema.textTheme.labelMedium,
                  ),
                ),

                // Error del servidor
                if (vm.estadoAuth == EstadoVigilante.error &&
                    vm.errorAuth.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(AppSpacing.radioBorde),
                      border: Border.all(color: AppColors.coralAccion),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_rounded,
                          color: AppColors.coralAccion, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(vm.errorAuth,
                          style: tema.textTheme.bodySmall)),
                    ]),
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                // Botón — verde institucional para vigilante
                ElevatedButton(
                  onPressed: cargando ? null : () => _iniciarSesion(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.exitoVerde,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: cargando
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.superficie0))
                      : const Text('Acceder',
                          style: TextStyle(color: AppColors.superficie0,
                              fontWeight: FontWeight.w500)),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Modo demo
                TextButton(
                  onPressed: cargando ? null : () {
                    _correoCtrl.text = 'j.mora@institucion.edu.mx';
                    _passCtrl.text   = 'Demo1234';
                    _telCtrl.text    = '5512345678';
                    AppLogger.info('LoginVigilanteView', 'Modo demo activado');
                  },
                  child: const Text('Modo demo offline',
                      style: TextStyle(color: AppColors.exitoVerde)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

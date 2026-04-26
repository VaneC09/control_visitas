// =============================================================================
// Archivo    : login_view.dart
// Módulo     : features/autorizador/presentation/views
// Descripción: Pantalla 1 — Login institucional del autorizador.
//              Valida correo y contraseña, consume AuthViewModel y navega
//              a la bandeja si la autenticación es exitosa.
// Autor      : Yadhira Andanely Benitez Millan
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

/// Pantalla de autenticación del autorizador.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Controladores de campos de texto
  final _correoCtrl    = TextEditingController();
  final _contrasenaCtrl = TextEditingController();

  // Clave global del formulario para validación
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Acción: iniciar sesión
  // ---------------------------------------------------------------------------

  Future<void> _iniciarSesion(BuildContext context) async {
    // Cerrar teclado
    FocusScope.of(context).unfocus();

    // Validar campos del formulario
    if (!(_formKey.currentState?.validate() ?? false)) return;

    AppLogger.accionUsuario('Botón Entrar presionado');

    await context.read<AuthViewModel>().login(
      correo:    _correoCtrl.text,
      contrasena: _contrasenaCtrl.text,
      onExito: () {
        AppLogger.navegacion(AppRoutes.bandeja);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.bandeja,
          (_) => false,  // Elimina toda la pila — no puede volver al login
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final tema   = Theme.of(context);
    final esCargando = authVM.estado == EstadoAuth.cargando;

    return Scaffold(
      backgroundColor: AppColors.superficie0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),

                // -------------------------------------------------------------
                // Logo
                // -------------------------------------------------------------
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

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Control de Aulas',
                  style: tema.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Sistema QR Institucional',
                  style: tema.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                // Badge de rol
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.azulNube,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Rol: Autorizador',
                    style: tema.textTheme.labelMedium?.copyWith(
                      color: AppColors.navyProfundo,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // -------------------------------------------------------------
                // Campo: correo institucional
                // -------------------------------------------------------------
                TextFormField(
                  controller: _correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enabled: !esCargando,
                  decoration: const InputDecoration(
                    labelText: 'Correo institucional',
                    prefixIcon: Icon(Icons.email_rounded),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa tu correo institucional';
                    }
                    if (!valor.contains('@') || !valor.contains('.')) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xs),

                // -------------------------------------------------------------
                // Campo: contraseña
                // -------------------------------------------------------------
                TextFormField(
                  controller: _contrasenaCtrl,
                  obscureText: authVM.ocultarContrasena,
                  textInputAction: TextInputAction.done,
                  enabled: !esCargando,
                  onFieldSubmitted: (_) => _iniciarSesion(context),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        authVM.ocultarContrasena
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: AppColors.encabezadoOscuro,
                      ),
                      onPressed: context
                          .read<AuthViewModel>()
                          .alternarVisibilidadContrasena,
                    ),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    if (valor.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),

                // -------------------------------------------------------------
                // Mensaje de error del servidor
                // -------------------------------------------------------------
                if (authVM.estado == EstadoAuth.error &&
                    authVM.mensajeError.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(AppSpacing.radioBorde),
                      border: Border.all(color: AppColors.coralAccion),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_rounded,
                            color: AppColors.coralAccion, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authVM.mensajeError,
                            style: tema.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                // -------------------------------------------------------------
                // Botón Entrar
                // -------------------------------------------------------------
                ElevatedButton(
                  onPressed: esCargando ? null : () => _iniciarSesion(context),
                  child: esCargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.superficie0,
                          ),
                        )
                      : const Text('Entrar'),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Enlace modo demo
                TextButton(
                  onPressed: esCargando
                      ? null
                      : () {
                          _correoCtrl.text  = 'yadhi.lopez@institucion.edu.mx';
                          _contrasenaCtrl.text = 'Demo1234';
                          AppLogger.info('LoginView', 'Modo demo activado');
                        },
                  child: const Text('Modo demo offline'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Archivo    : main.dart
// Módulo     : lib/
// Descripción: Punto de entrada de la aplicación CA — Control de Visitas.
//              Inicializa el árbol de Providers (MVVM), configura el tema
//              institucional OMEGA y registra las rutas nombradas.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.2.0
// Fecha      : 2026-04-27
// Cambios    : v1.1.0 — SolicitanteProvider integrado
//              v1.2.0 — VigilanteViewModel agregado al MultiProvider
//                       Se conserva initializeDateFormatting del main original
//                       Se corrige import de app_theme (core/theme/ vs core/config/)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/config/app_colors.dart';
import 'core/config/app_routes.dart';
import 'core/theme/app_theme.dart';           // ← ruta original del proyecto
import 'core/utils/app_logger.dart';
import 'features/autorizador/bloc/auth_viewmodel.dart';
import 'features/autorizador/bloc/bandeja_viewmodel.dart';
import 'features/solicitante/bloc/solicitante_provider.dart'; // ← conservado
import 'features/vigilante/bloc/vigilante_viewmodel.dart';    // ← NUEVO

/// Punto de entrada de la aplicación.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar datos de localización en español México (para intl / DateFormat)
  await initializeDateFormatting('es_MX', null);

  // Bloquear orientación a modo retrato
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Estilo de la barra de estado del sistema
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:     Brightness.light,
    ),
  );

  AppLogger.info('main', 'Aplicación CA — Control de Visitas iniciada v1.2.0');
  runApp(const CaApp());
}

/// Widget raíz de la aplicación CA — Control de Visitas.
class CaApp extends StatelessWidget {
  const CaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Autorizador ──────────────────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => BandejaViewModel()),

        // ── Solicitante ──────────────────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => SolicitanteProvider()),

        // ── Vigilante ────────────────────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => VigilanteViewModel()),
      ],
      child: MaterialApp(
        title:                     'CA — Control de Visitas',
        debugShowCheckedModeBanner: false,
        theme:                     AppTheme.temaClaro,
        initialRoute:              AppRoutes.seleccionRol,
        routes:                    rutasApp,
        color:                     AppColors.superficie0,
        // TODO: Agregar flutter_localizations cuando se active i18n (MPF §6.4)
      ),
    );
  }
}

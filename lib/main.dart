// =============================================================================
// Archivo    : main.dart
// Módulo     : lib/
// Descripción: Punto de entrada de la aplicación control de visitas
//              Inicializa el árbol de Providers (MVVM), configura el tema
//              institucional OMEGA y registra las rutas nombradas.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/config/app_colors.dart';
import 'core/config/app_routes.dart';
import 'core/config/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'features/autorizador/bloc/auth_viewmodel.dart';
import 'features/autorizador/bloc/bandeja_viewmodel.dart';

/// Punto de entrada de la aplicación.
/// Establece orientación, barra de estado y árbol de Providers.
void main() {
  // Garantizar inicialización del binding antes de configuraciones de plataforma
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquear orientación a modo retrato (móvil institucional)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Estilo de la barra de estado del sistema
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:            Colors.transparent,
      statusBarIconBrightness:   Brightness.dark,
      statusBarBrightness:       Brightness.light,
    ),
  );

  AppLogger.info('main', 'Aplicación CA iniciada');
  runApp(const CaApp());
}

/// Widget raíz de la aplicación CA — Control de Aulas.
///
/// Registra los ViewModels disponibles en el árbol de widgets mediante
/// [MultiProvider], siguiendo el patrón MVVM (MPF-OMEGA-04 §6.1).
class CaApp extends StatelessWidget {
  const CaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ViewModel de autenticación — ciclo de vida de sesión
        ChangeNotifierProvider(create: (_) => AuthViewModel()),

        // ViewModel de la bandeja — solicitudes pendientes
        ChangeNotifierProvider(create: (_) => BandejaViewModel()),
      ],
      child: MaterialApp(
        // -----------------------------------------------------------------------
        // Metadatos de la aplicación
        // -----------------------------------------------------------------------
        title: 'CA — Control de Aulas',
        debugShowCheckedModeBanner: false,

        // -----------------------------------------------------------------------
        // Tema institucional OMEGA (MPF-OMEGA-04 7)
        // -----------------------------------------------------------------------
        theme: AppTheme.temaClaro,

        // -----------------------------------------------------------------------
        // Ruta inicial y mapa de rutas nombradas
        // -----------------------------------------------------------------------
        initialRoute: AppRoutes.seleccionRol,
        routes:       rutasApp,

        // -----------------------------------------------------------------------
        // Color de fondo durante arranque (evita flash blanco)
        // -----------------------------------------------------------------------
        color: AppColors.superficie0,

        // -----------------------------------------------------------------------
        // Configuración de localización (español México)
        // -----------------------------------------------------------------------
        // TODO: Agregar flutter_localizations cuando se active i18n 
        // localizationsDelegates: AppLocalizations.localizationsDelegates,
        // supportedLocales:       AppLocalizations.supportedLocales,
        // locale:                 const Locale('es', 'MX'),
      ),
    );
  }
}

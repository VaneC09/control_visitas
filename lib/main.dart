// =============================================================================
// Archivo    : main.dart
// Módulo     : lib/
// Descripción: Punto de entrada de la aplicación control de visitas
//              Inicializa el árbol de Providers (MVVM), configura el tema
//              institucional OMEGA y registra las rutas nombradas.
// Autor      : OMEGA Solutions
// Versión    : 1.0.0
// Fecha      : 2026-04-26
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/app_colors.dart';
import 'core/config/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'features/autorizador/bloc/auth_viewmodel.dart';
import 'features/autorizador/bloc/bandeja_viewmodel.dart';
import 'features/solicitante/bloc/solicitante_provider.dart';

/// Punto de entrada de la aplicación.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_MX', null);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:     Brightness.light,
    ),
  );

  AppLogger.info('main', 'Aplicación CA iniciada');
  runApp(const CaApp());
}

/// Widget raíz de la aplicación CA.
class CaApp extends StatelessWidget {
  const CaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => BandejaViewModel()),
        ChangeNotifierProvider(create: (_) => SolicitanteProvider()),
      ],
      child: MaterialApp(
        title: 'CA — Control de Aulas',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.temaClaro,
        initialRoute: AppRoutes.seleccionRol,
        routes:      rutasApp,
        color: AppColors.superficie0,
        // TODO: Agregar flutter_localizations cuando se active i18n
      ),
    );
  }
}
// =============================================================================
// Archivo    : vigilante_exports.dart
// Módulo     : features/vigilante
// Descripción: Archivo barrel del módulo vigilante.
//              Exporta todos los componentes públicos del módulo para
//              uso limpio desde otros módulos (MPF-OMEGA-04 §3.4).
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-27
// =============================================================================

// ViewModel
export 'bloc/vigilante_viewmodel.dart';

// Modelos
export 'data/models/vigilante_model.dart';
export 'data/models/resultado_escaneo_model.dart';
export 'data/models/visita_hoy_model.dart';

// Repositorio
export 'data/repositories/vigilante_repositorio.dart';

// Vistas
export 'presentation/views/login_vigilante_view.dart';
export 'presentation/views/home_vigilante_view.dart';
export 'presentation/views/escaner_qr_view.dart';
export 'presentation/views/resultado_escaneo_view.dart';
export 'presentation/views/espera_prorroga_view.dart';
export 'presentation/views/visita_espontanea_view.dart';
export 'presentation/views/proximas_visitas_view.dart';

// =============================================================================
// Archivo    : app_spacing.dart
// Módulo     : core/constants
// Descripción: Sistema de espaciado atómico de 8 puntos.
//              Toda la interfaz usa esta escala.(MPF-OMEGA-04 §7.1).
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

/// Constantes de espaciado basadas en la escala de 8dp (MPF-OMEGA-04 §7.1).
/// Usar en SizedBox, Padding y EdgeInsets de toda la app.
class AppSpacing {
  AppSpacing._();

  /// 8dp — Separación mínima entre iconos y texto
  static const double xs = 8.0;

  /// 16dp — Gutter en móviles y paddings internos
  static const double sm = 16.0;

  /// 24dp — Separación entre componentes principales
  static const double md = 24.0;

  /// 32dp — Gutter en tablets y secciones amplias
  static const double lg = 32.0;

  /// 40dp — Área táctil mínima / separación entre bloques
  static const double xl = 40.0;

  /// 48dp — Espaciado amplio entre grupos de interfaz
  static const double xxl = 48.0;

  // Alias para tamaños táctiles (MPF-OMEGA-04 §7.5.1)
  static const double alturaMinBoton  = 48.0;
  static const double alturaMinInput  = 48.0;
  static const double radioBorde      = 8.0;
  static const double radioBordeLg    = 12.0;
}
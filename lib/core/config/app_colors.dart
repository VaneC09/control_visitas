// =============================================================================
// Archivo    : app_colors.dart
// Módulo     : core/config
// Descripción: Paleta de colores institucional OMEGA centralizada..
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// Referencia : Manual MPF-OMEGA-04 §7.7.1 — Paleta de colores institucional
// =============================================================================

import 'package:flutter/material.dart';

/// Paleta de colores institucional OMEGA.
/// Todos los componentes deben referenciar estos valores.
/// No se permiten colores hardcoded en widgets individuales.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Superficies
  // ---------------------------------------------------------------------------

  /// Fondo del Scaffold y celdas de tabla impares — Nivel 0
  static const Color superficie0 = Color(0xFFFFFDFC);

  /// Cards, Drawer, separadores e inputs deshabilitados — Nivel 1
  static const Color superficie1 = Color(0xFFEBE1DF);

  /// Fondos de selección y filas cebra en tablas — Interacción
  static const Color sutilCalido = Color(0xFFFAEFED);

  // ---------------------------------------------------------------------------
  // Marca / Énfasis
  // ---------------------------------------------------------------------------

  /// Botones primarios, iconos activos y resaltados
  static const Color coralPrimario = Color(0xFFF28B66);

  /// Warning Alert y mensajes de precaución
  static const Color coralSutil = Color(0xFFFFAE91);

  /// Danger Alert, Question Alert y botones destructivos
  static const Color coralAccion = Color(0xFFD77552);

  // ---------------------------------------------------------------------------
  // Navegación / Informativo
  // ---------------------------------------------------------------------------

  /// Cabeceras de tablas y banners informativos
  static const Color azulCielo = Color(0xFF9ABBC9);

  /// Fondos de Badges y resaltado de estados secundarios
  static const Color azulNube = Color(0xFFD2ECF7);

  /// Info Alert y estados resaltados de información
  static const Color azulElectrico = Color(0xFF1E90FF);

  // ---------------------------------------------------------------------------
  // Estado
  // ---------------------------------------------------------------------------

  /// Success Alert e indicadores de procesos completados
  static const Color exitoVerde = Color(0xFF10B981);

  // ---------------------------------------------------------------------------
  // Tipografía
  // ---------------------------------------------------------------------------

  /// Títulos Nivel 1 y encabezados de diálogos
  static const Color navyProfundo = Color(0xFF233B54);

  /// Basic Alert, iconos inactivos y bordes de input en foco
  static const Color encabezadoOscuro = Color(0xFF517399);

  /// Labels de formularios (Nivel 4) y texto de apoyo
  static const Color azulAcero = Color(0xFF405A75);

  /// Texto de cuerpo principal (Nivel 3)
  static const Color grisOnyx = Color(0xFF303030);

  /// Fondos de SnackBars de alto contraste
  static const Color pizarraNegra = Color(0xFF1F2937);

  /// Ítems inactivos en menús (Nivel 2) y texto secundario
  static const Color grisNeutral = Color(0xFF595959);

  // ---------------------------------------------------------------------------
  // Bordes de inputs
  // ---------------------------------------------------------------------------

  /// Borde de input en estado Normal
  static const Color bordeInput = Color(0xFFB2CFDB);

  // ---------------------------------------------------------------------------
  // Semánticos (alias de conveniencia)
  // ---------------------------------------------------------------------------

  static const Color primario     = coralPrimario;
  static const Color error        = coralAccion;
  static const Color exito        = exitoVerde;
  static const Color advertencia  = coralSutil;
  static const Color informativo  = azulCielo;
  static const Color fondo        = superficie0;
  static const Color contenedor   = superficie1;
}
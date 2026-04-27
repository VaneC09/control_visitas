// =============================================================================
// Archivo    : app_theme.dart
// Módulo     : core/config
// Descripción: ThemeData institucional OMEGA para Flutter.
//              Toda tipografía y colores se controlan desde aquí.
//              (MPF-OMEGA-04).
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../constants/app_spacing.dart';

/// Tema institucional OMEGA — Modo claro.
class AppTheme {
  AppTheme._();

  static ThemeData get temaClaro {
    // Esquema de colores Material 3
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.coralPrimario,
      brightness: Brightness.light,
      primary:   AppColors.coralPrimario,
      onPrimary: AppColors.superficie0,
      secondary: AppColors.encabezadoOscuro,
      error:     AppColors.coralAccion,
      surface:   AppColors.superficie0,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Fondo general del Scaffold (MPF-OMEGA-04 §7.7.1 — Base Surface)
      scaffoldBackgroundColor: AppColors.superficie0,

      // -----------------------------------------------------------------------
      // Tipografía institucional (MPF-OMEGA-04 §7.2)
      // Montserrat → Display, H1, H2, H3, Acción
      // Inter      → Body Large, Body, Caption
      // -----------------------------------------------------------------------
      textTheme: TextTheme(
        // Display / H1 — 32px, SemiBold, #233B54
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.navyProfundo),

        // H2 / Nivel 1 — 24px, SemiBold, #233B54
        displayMedium: GoogleFonts.montserrat(
          fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.navyProfundo),

        // H3 / Nivel 2 — 20px, SemiBold, #000000
        displaySmall: GoogleFonts.montserrat(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),

        // Título de pantalla principal
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.navyProfundo),

        headlineMedium: GoogleFonts.montserrat(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.navyProfundo),

        headlineSmall: GoogleFonts.montserrat(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.navyProfundo),

        // Acción — 14px, SemiBold, #F28B66 (botones y links)
        titleLarge: GoogleFonts.montserrat(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.navyProfundo),

        titleMedium: GoogleFonts.montserrat(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.coralPrimario),

        // Body Large / Nivel 3 — 16px, Regular, #303030
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.grisOnyx),

        // Body / Nivel 4 — 14px, Medium, #405A75
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.azulAcero),

        // Caption Error — 12px, Regular, #D77552
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.coralAccion),

        // Caption Success — 12px, Regular, #10B981
        labelSmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.exitoVerde),

        labelMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.grisNeutral),

        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.superficie0),
      ),

      // -----------------------------------------------------------------------
      // AppBar
      // -----------------------------------------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.superficie0,
        foregroundColor: AppColors.navyProfundo,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.navyProfundo),
        iconTheme: const IconThemeData(color: AppColors.encabezadoOscuro),
      ),

      // -----------------------------------------------------------------------
      // Botón Primario (MPF-OMEGA-04 §7.5.1)
      // -----------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coralPrimario,
          foregroundColor: AppColors.superficie0,
          minimumSize: const Size(double.infinity, AppSpacing.alturaMinBoton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          elevation: 2,
        ),
      ),

      // -----------------------------------------------------------------------
      // Botón Secundario
      // -----------------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.encabezadoOscuro,
          side: const BorderSide(color: AppColors.encabezadoOscuro, width: 1),
          minimumSize: const Size(88, AppSpacing.alturaMinBoton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // -----------------------------------------------------------------------
      // Botón de texto
      // -----------------------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.encabezadoOscuro,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // -----------------------------------------------------------------------
      // Inputs (MPF-OMEGA-04 §7.1.4)
      // -----------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie0,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radioBorde),
          borderSide: const BorderSide(color: AppColors.bordeInput),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radioBorde),
          borderSide: const BorderSide(color: AppColors.bordeInput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radioBorde),
          borderSide: const BorderSide(color: AppColors.encabezadoOscuro, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radioBorde),
          borderSide: const BorderSide(color: AppColors.coralAccion),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radioBorde),
          borderSide: const BorderSide(color: AppColors.coralAccion, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.azulAcero),
        hintStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.grisNeutral),
        errorStyle: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.coralAccion),
      ),

      // -----------------------------------------------------------------------
      // Cards (MPF-OMEGA-04 §7.5.4)
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: AppColors.superficie0,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radioBordeLg),
          side: const BorderSide(color: AppColors.superficie1),
        ),
        margin: EdgeInsets.zero,
      ),

      // -----------------------------------------------------------------------
      // Dividers
      // -----------------------------------------------------------------------
      dividerColor: AppColors.superficie1,
      dividerTheme: const DividerThemeData(
        color: AppColors.superficie1,
        thickness: 0.5,
      ),
    );
  }
}

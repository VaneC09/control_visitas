// =============================================================================
// Archivo    : solicitud_model.dart
// Módulo     : features/solicitante/data/models
// Descripción: Modelo de solicitud del módulo solicitante.
//              IMPORTANTE: Re-exporta el modelo del autorizador para evitar
//              duplicidad. Ambos módulos usan exactamente el mismo modelo.
// Ruta       : lib/features/solicitante/data/models/solicitud_model.dart
// =============================================================================

// Re-exporta el modelo unificado del autorizador
export 'package:control_visitas/features/autorizador/data/models/solicitud_model.dart';
export 'package:control_visitas/features/autorizador/data/models/visitante_model.dart';

// ---------------------------------------------------------------------------
// CatalogoModel — solo existe aquí porque es exclusivo del solicitante
// ---------------------------------------------------------------------------

/// Modelo para catálogos (motivos de visita, lugares de encuentro).
// Re-exporta modelo compartido
export 'package:control_visitas/features/autorizador/data/models/solicitud_model.dart';

// Visitante compartido
export 'package:control_visitas/features/autorizador/data/models/visitante_model.dart';

class CatalogoModel {
  final String id;
  final String nombre;
  final String? descripcion;

  const CatalogoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory CatalogoModel.fromJson(Map<String, dynamic> json) {
    return CatalogoModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
    );
  }
}
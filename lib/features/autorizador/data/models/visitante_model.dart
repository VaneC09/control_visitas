// =============================================================================
// Archivo    : visitante_model.dart
// Módulo     : features/autorizador/data/models
// Descripción: Modelo de visitante externo con serialización JSON.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-25
// =============================================================================

/// Persona externa que visita la institución.
class VisitanteModel {
  final int    idVisitante;
  final String nombre;
  final String apellidos;
  final String correoPersonal;

  const VisitanteModel({
    required this.idVisitante,
    required this.nombre,
    required this.apellidos,
    required this.correoPersonal,
  });

  factory VisitanteModel.fromJson(Map<String, dynamic> json) => VisitanteModel(
    idVisitante:   json['idVisitante']   as int?    ?? 0,
    nombre:        json['nombre']        as String? ?? '',
    apellidos:     json['apellidos']     as String? ?? '',
    correoPersonal:json['correoPersonal']as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'idVisitante':    idVisitante,
    'nombre':         nombre,
    'apellidos':      apellidos,
    'correoPersonal': correoPersonal,
  };

  /// Nombre completo del visitante.
  String get nombreCompleto => '$nombre $apellidos';
}
// =============================================================================
// Archivo    : visitante_model.dart
// Módulo     : features/autorizador/data/models
// Ruta       : lib/features/autorizador/data/models/visitante_model.dart
//
// CORRECCIÓN: idVisitante ahora es opcional (int? con default 0)
//             para poder crear instancias vacías en el wizard sin pasar el id.
// =============================================================================

class VisitanteModel {
  final int    idVisitante;   // 0 = visitante nuevo sin id aún
  final String nombre;
  final String apellidos;
  final String correoPersonal;

  const VisitanteModel({
    this.idVisitante = 0,     // ← CORRECCIÓN: opcional con default 0
    required this.nombre,
    required this.apellidos,
    required this.correoPersonal,
  });

  String get nombreCompleto => '$nombre $apellidos'.trim();

  factory VisitanteModel.fromJson(Map<String, dynamic> json) => VisitanteModel(
    idVisitante:    json['idVisitante']    as int?    ?? 0,
    nombre:         json['nombre']         as String? ?? '',
    apellidos:      json['apellidos']      as String? ?? '',
    correoPersonal: json['correoPersonal'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'idVisitante':    idVisitante,
    'nombre':         nombre,
    'apellidos':      apellidos,
    'correoPersonal': correoPersonal,
  };
}
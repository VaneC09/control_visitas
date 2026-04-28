// =============================================================================
// Archivo    : vigilante_model.dart
// Módulo     : features/vigilante/data/models
// Descripción: Modelo del vigilante autenticado. Inmutable, con fromJson/toJson.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-27
// =============================================================================

/// Representa al vigilante de seguridad autenticado en la app.
class VigilanteModel {
  final int    idVigilante;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String numeroTelefono;
  final String correo;

  const VigilanteModel({
    required this.idVigilante,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.numeroTelefono,
    required this.correo,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno';

  factory VigilanteModel.fromJson(Map<String, dynamic> json) => VigilanteModel(
    idVigilante:     json['idVigilante']     as int?    ?? 0,
    nombre:          json['nombre']          as String? ?? '',
    apellidoPaterno: json['apellidoPaterno'] as String? ?? '',
    apellidoMaterno: json['apellidoMaterno'] as String? ?? '',
    numeroTelefono:  json['numeroTelefono']  as String? ?? '',
    correo:          json['correo']          as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'idVigilante':     idVigilante,
    'nombre':          nombre,
    'apellidoPaterno': apellidoPaterno,
    'apellidoMaterno': apellidoMaterno,
    'numeroTelefono':  numeroTelefono,
    'correo':          correo,
  };
}
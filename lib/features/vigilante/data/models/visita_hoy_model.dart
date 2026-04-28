// =============================================================================
// Archivo    : visita_hoy_model.dart
// Módulo     : features/vigilante/data/models
// Descripción: Modelo de una visita programada para el día actual.
//              Usado en la pantalla de "Próximas visitas".
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-27
// =============================================================================

/// Visita aprobada para el día de hoy visible al vigilante.
class VisitaHoyModel {
  final int    idSolicitud;
  final String fechaInicio;
  final String estadoSolicitud;
  final String tipoSolicitud;
  final String lugarEncuentro;
  final String nombreAnfitrion;
  final String departamento;
  final int?   idQr;
  final String codigoQr;
  final String estadoQr;
  final String nombreVisitante;

  const VisitaHoyModel({
    required this.idSolicitud,
    required this.fechaInicio,
    required this.estadoSolicitud,
    required this.tipoSolicitud,
    required this.lugarEncuentro,
    required this.nombreAnfitrion,
    required this.departamento,
    this.idQr,
    this.codigoQr = '',
    this.estadoQr = '',
    this.nombreVisitante = '',
  });

  /// Hora formateada HH:mm extraída del ISO datetime.
  String get hora {
    if (fechaInicio.length >= 16) return fechaInicio.substring(11, 16);
    return '';
  }

  factory VisitaHoyModel.fromJson(Map<String, dynamic> json) => VisitaHoyModel(
    idSolicitud:     json['idSolicitud']    as int?    ?? 0,
    fechaInicio:     json['fechaInicio']    as String? ?? '',
    estadoSolicitud: json['estadoSolicitud']as String? ?? '',
    tipoSolicitud:   json['tipoSolicitud']  as String? ?? '',
    lugarEncuentro:  json['lugarEncuentro'] as String? ?? '',
    nombreAnfitrion: json['nombreAnfitrion']as String? ?? '',
    departamento:    json['departamento']   as String? ?? '',
    idQr:            json['idQr']           as int?,
    codigoQr:        json['codigoQr']       as String? ?? '',
    estadoQr:        json['estadoQr']       as String? ?? '',
    nombreVisitante: json['nombreVisitante']as String? ?? '',
  );
}

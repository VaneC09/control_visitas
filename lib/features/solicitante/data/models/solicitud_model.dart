// =============================================================================
// Archivo: solicitud_model.dart
// Módulo: solicitante/data/models
// Descripción: Modelo de datos para solicitudes de visita del solicitante.
// Autor: OMEGA Solutions
// Versión: 1.0
// Fecha: 2026-04-26
// =============================================================================

/// Modelo que representa una solicitud de visita.
class SolicitudModel {
  final int? idSolicitud;
  final String fechaInicio;
  final int toleranciaAntes;
  final int toleranciaDespues;
  final bool prorrogaTolerancias;
  final String? fechaCreacion;
  final String idEstadoSolicitud;
  final String nombreEstado;
  final String idTipoSolicitud;
  final String idLugarEncuentro;
  final String idMotivoVisita;
  final String? descripcionMotivo;
  final int? idGrupo;
  final List<VisitanteModel> visitantes;

  const SolicitudModel({
    this.idSolicitud,
    required this.fechaInicio,
    required this.toleranciaAntes,
    required this.toleranciaDespues,
    required this.prorrogaTolerancias,
    this.fechaCreacion,
    required this.idEstadoSolicitud,
    required this.nombreEstado,
    required this.idTipoSolicitud,
    required this.idLugarEncuentro,
    required this.idMotivoVisita,
    this.descripcionMotivo,
    this.idGrupo,
    this.visitantes = const [],
  });

  factory SolicitudModel.fromJson(Map<String, dynamic> json) {
    return SolicitudModel(
      idSolicitud: json['id_solicitud'] as int?,
      fechaInicio: json['fecha_inicio'] as String? ?? '',
      toleranciaAntes: json['tolerancia_antes'] as int? ?? 15,
      toleranciaDespues: json['tolerancia_despues'] as int? ?? 15,
      prorrogaTolerancias: json['prorroga_tolerancia'] as bool? ?? false,
      fechaCreacion: json['fecha_creacion'] as String?,
      idEstadoSolicitud: json['id_estado_solicitud']?.toString() ?? 'pendiente',
      nombreEstado: json['nombre_estado'] as String? ?? 'Pendiente',
      idTipoSolicitud: json['id_tipo_solicitud']?.toString() ?? '',
      idLugarEncuentro: json['id_lugar_encuentro']?.toString() ?? '',
      idMotivoVisita: json['id_motivo_visita']?.toString() ?? '',
      descripcionMotivo: json['descripcion_motivo'] as String?,
      idGrupo: json['id_grupo'] as int?,
      visitantes: (json['visitantes'] as List<dynamic>?)
              ?.map((v) => VisitanteModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idSolicitud != null) 'id_solicitud': idSolicitud,
      'fecha_inicio': fechaInicio,
      'tolerancia_antes': toleranciaAntes,
      'tolerancia_despues': toleranciaDespues,
      'prorroga_tolerancia': prorrogaTolerancias,
      'id_estado_solicitud': idEstadoSolicitud,
      'id_tipo_solicitud': idTipoSolicitud,
      'id_lugar_encuentro': idLugarEncuentro,
      'id_motivo_visita': idMotivoVisita,
      if (descripcionMotivo != null) 'descripcion_motivo': descripcionMotivo,
      if (idGrupo != null) 'id_grupo': idGrupo,
      'visitantes': visitantes.map((v) => v.toJson()).toList(),
    };
  }
}

/// Modelo que representa un visitante dentro de una solicitud.
class VisitanteModel {
  final int? idVisitante;
  final String nombre;
  final String apellidos;
  final String correoPersonal;

  const VisitanteModel({
    this.idVisitante,
    required this.nombre,
    required this.apellidos,
    required this.correoPersonal,
  });

  factory VisitanteModel.fromJson(Map<String, dynamic> json) {
    return VisitanteModel(
      idVisitante: json['id_visitante'] as int?,
      nombre: json['nombre'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      correoPersonal: json['correo_personal'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idVisitante != null) 'id_visitante': idVisitante,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo_personal': correoPersonal,
    };
  }

  /// Nombre completo del visitante.
  String get nombreCompleto => '$nombre $apellidos'.trim();
}

/// Modelo para catálogos (motivo, lugar, tipo, estado).
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

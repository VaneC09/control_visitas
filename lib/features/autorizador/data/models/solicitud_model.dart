// =============================================================================
// Archivo    : solicitud_model.dart
// Módulo     : features/autorizador/data/models
// Descripción: Modelo unificado de solicitud de visita.
//              Compatible con el repositorio local SQLite y con la futura
//              API Laravel. Usa exactamente los nombres del ER.
// Ruta       : lib/features/autorizador/data/models/solicitud_model.dart
// =============================================================================

import 'visitante_model.dart';

/// Modelo de solicitud de visita.
/// Inmutable — no modificar propiedades después de construirlo.
class SolicitudModel {
  final int    idSolicitud;
  final String fechaInicio;
  final int    toleranciaAntes;
  final int    toleranciaDespues;
  // CORRECCIÓN: campo unificado — era prorrogaToleran en algunos archivos
  final bool   prorrogaTolerancia;
  final String observaciones;
  final String fechaCreacion;
  // CORRECCIÓN: campo 'estado' = nombre del estado (pendiente, aprobada, etc.)
  final String estado;
  final String tipoSolicitud;
  final String lugarEncuentro;
  final String motivoVisita;
  final int    idSolicitante;
  final String nombreSolicitante;
  final String departamentoSolicitante;
  final String correoSolicitante;
  final int    idAutorizador;
  final String nombreAutorizador;
  final List<VisitanteModel> visitantes;

  const SolicitudModel({
    required this.idSolicitud,
    required this.fechaInicio,
    required this.toleranciaAntes,
    required this.toleranciaDespues,
    required this.prorrogaTolerancia,
    required this.observaciones,
    required this.fechaCreacion,
    required this.estado,
    required this.tipoSolicitud,
    required this.lugarEncuentro,
    required this.motivoVisita,
    required this.idSolicitante,
    required this.nombreSolicitante,
    required this.departamentoSolicitante,
    required this.correoSolicitante,
    required this.idAutorizador,
    required this.nombreAutorizador,
    required this.visitantes,
  });

  // ---------------------------------------------------------------------------
  // Deserialización desde JSON de la API futura
  // ---------------------------------------------------------------------------
  factory SolicitudModel.fromJson(Map<String, dynamic> json) {
    final visitantesJson = json['visitantes'] as List<dynamic>? ?? [];
    final visitantes = visitantesJson
        .map((v) => VisitanteModel.fromJson(v as Map<String, dynamic>))
        .toList();

    return SolicitudModel(
      idSolicitud:             json['idSolicitud']            as int?    ?? 0,
      fechaInicio:             json['fechaInicio']            as String? ?? '',
      toleranciaAntes:         json['toleranciaAntes']        as int?    ?? 15,
      toleranciaDespues:       json['toleranciaDespues']      as int?    ?? 15,
      prorrogaTolerancia:      json['prorrogaToleran']        as bool?   ?? false,
      observaciones:           json['observaciones']          as String? ?? '',
      fechaCreacion:           json['fechaCreacion']          as String? ?? '',
      estado:                  json['estado']                 as String? ?? '',
      tipoSolicitud:           json['tipoSolicitud']          as String? ?? '',
      lugarEncuentro:          json['lugarEncuentro']         as String? ?? '',
      motivoVisita:            json['motivoVisita']           as String? ?? '',
      idSolicitante:           json['idSolicitante']          as int?    ?? 0,
      nombreSolicitante:       json['nombreSolicitante']      as String? ?? '',
      departamentoSolicitante: json['departamentoSolicitante']as String? ?? '',
      correoSolicitante:       json['correoSolicitante']      as String? ?? '',
      idAutorizador:           json['idAutorizador']          as int?    ?? 0,
      nombreAutorizador:       json['nombreAutorizador']      as String? ?? '',
      visitantes:              visitantes,
    );
  }

  // Serialización para logs / caché
  Map<String, dynamic> toJson() => {
    'idSolicitud':             idSolicitud,
    'fechaInicio':             fechaInicio,
    'toleranciaAntes':         toleranciaAntes,
    'toleranciaDespues':       toleranciaDespues,
    'prorrogaToleran':         prorrogaTolerancia,
    'observaciones':           observaciones,
    'fechaCreacion':           fechaCreacion,
    'estado':                  estado,
    'tipoSolicitud':           tipoSolicitud,
    'lugarEncuentro':          lugarEncuentro,
    'motivoVisita':            motivoVisita,
    'idSolicitante':           idSolicitante,
    'nombreSolicitante':       nombreSolicitante,
    'departamentoSolicitante': departamentoSolicitante,
    'correoSolicitante':       correoSolicitante,
    'idAutorizador':           idAutorizador,
    'nombreAutorizador':       nombreAutorizador,
    'visitantes':              visitantes.map((v) => v.toJson()).toList(),
  };
}
// =============================================================================
// Archivo    : resultado_escaneo_model.dart
// Módulo     : features/vigilante/data/models
// Descripción: Modelo de respuesta al escanear un código QR.
//              Refleja el contrato del endpoint POST /api/qr/scan.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-27
// =============================================================================

/// Estados posibles devueltos por el backend al escanear un QR.
enum EstadoEscaneo {
  validoEntrada,
  validoSalida,
  vencido,
  enListaExclusion,
  noEncontrado,
  yaUtilizado,
  solicitudCancelada,
  desconocido,
}

/// Resultado completo del escaneo de un código QR.
class ResultadoEscaneoModel {
  final EstadoEscaneo estado;
  final String        mensaje;
  final String        horaActual;
  final bool          permiteProrroga;

  // Datos del QR y visitante
  final int?   idQr;
  final String codigoQr;
  final String nombreVisitante;
  final String correoVisitante;

  // Destino
  final String nombreAnfitrion;
  final String departamento;

  // Horario
  final String fechaVisita;
  final String horaVisita;
  final int    toleranciaAntes;
  final int    toleranciaDespues;

  // Registro
  final int?   idRegistro;
  final String horaEntradaRegistrada;

  const ResultadoEscaneoModel({
    required this.estado,
    required this.mensaje,
    required this.horaActual,
    required this.permiteProrroga,
    this.idQr,
    this.codigoQr = '',
    this.nombreVisitante = '',
    this.correoVisitante = '',
    this.nombreAnfitrion = '',
    this.departamento = '',
    this.fechaVisita = '',
    this.horaVisita = '',
    this.toleranciaAntes = 15,
    this.toleranciaDespues = 15,
    this.idRegistro,
    this.horaEntradaRegistrada = '',
  });

  /// Convierte el string del backend al enum local.
  static EstadoEscaneo _mapearEstado(String? raw) => switch (raw) {
    'VALIDO_ENTRADA'     => EstadoEscaneo.validoEntrada,
    'VALIDO_SALIDA'      => EstadoEscaneo.validoSalida,
    'VENCIDO'            => EstadoEscaneo.vencido,
    'EN_LISTA_EXCLUSION' => EstadoEscaneo.enListaExclusion,
    'NO_ENCONTRADO'      => EstadoEscaneo.noEncontrado,
    'YA_UTILIZADO'       => EstadoEscaneo.yaUtilizado,
    'SOLICITUD_CANCELADA'=> EstadoEscaneo.solicitudCancelada,
    _                    => EstadoEscaneo.desconocido,
  };

  factory ResultadoEscaneoModel.fromJson(Map<String, dynamic> json) =>
      ResultadoEscaneoModel(
        estado:               _mapearEstado(json['estado'] as String?),
        mensaje:              json['mensaje']              as String? ?? '',
        horaActual:           json['horaActual']           as String? ?? '',
        permiteProrroga:      json['permiteProrroga']      as bool?   ?? false,
        idQr:                 json['idQr']                 as int?,
        codigoQr:             json['codigoQr']             as String? ?? '',
        nombreVisitante:      json['nombreVisitante']      as String? ?? '',
        correoVisitante:      json['correoVisitante']      as String? ?? '',
        nombreAnfitrion:      json['nombreAnfitrion']      as String? ?? '',
        departamento:         json['departamento']         as String? ?? '',
        fechaVisita:          json['fechaVisita']          as String? ?? '',
        horaVisita:           json['horaVisita']           as String? ?? '',
        toleranciaAntes:      json['toleranciaAntes']      as int?    ?? 15,
        toleranciaDespues:    json['toleranciaDespues']    as int?    ?? 15,
        idRegistro:           json['idRegistro']           as int?,
        horaEntradaRegistrada:json['horaEntradaRegistrada']as String? ?? '',
      );
}

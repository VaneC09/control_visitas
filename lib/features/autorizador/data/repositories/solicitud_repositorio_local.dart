// =============================================================================
// Archivo    : solicitud_repositorio_local.dart
// Módulo     : features/autorizador/data/repositories
// Descripción: Repositorio SQLite local. Implementa TODAS las reglas de
//              negocio sin depender de Laravel ni de internet.
//              Este archivo es el ÚNICO repositorio de datos. Tanto el módulo
//              autorizador, solicitante como vigilante lo importan desde aquí.
//
// RUTA ÚNICA: lib/features/autorizador/data/repositories/solicitud_repositorio_local.dart
//
// Para importarlo desde solicitante:
//   import 'package:control_visitas/features/autorizador/data/repositories/solicitud_repositorio_local.dart';
// Para importarlo desde vigilante:
//   import 'package:control_visitas/features/autorizador/data/repositories/solicitud_repositorio_local.dart';
// =============================================================================

import 'dart:math';
import 'package:sqflite/sqflite.dart';

import 'package:control_visitas/core/database/local_database.dart';
import 'package:control_visitas/core/errors/exceptions.dart';
import 'package:control_visitas/core/services/session_service.dart';
import 'package:control_visitas/core/utils/app_logger.dart';
import 'package:control_visitas/features/autorizador/data/models/solicitud_model.dart';
import 'package:control_visitas/features/autorizador/data/models/visitante_model.dart';

/// Repositorio único de datos local (SQLite).
/// Todos los módulos (autorizador, solicitante, vigilante) usan esta clase.
class SolicitudRepositorioLocal {
  final _local = LocalDatabase.instancia;
  final _sess  = SessionService.instancia;

  // ══════════════════════════════════════════════════════════════════════════
  // VISITANTES
  // ══════════════════════════════════════════════════════════════════════════

  /// R3 — Verifica si un visitante está en la lista de exclusión.
  Future<bool> estaVetado(int idVisitante) async {
    final db = await _local.db;
    final r = await db.query(
      'lista_exclusion',
      where: 'id_visitante = ?',
      whereArgs: [idVisitante],
      limit: 1,
    );
    return r.isNotEmpty;
  }

  /// Busca un visitante por correo. Retorna su id o null si no existe.
  Future<int?> buscarVisitantePorCorreo(String correo) async {
    final db = await _local.db;
    final r = await db.query(
      'visitante',
      where: 'correo_personal = ?',
      whereArgs: [correo.trim().toLowerCase()],
      limit: 1,
    );
    if (r.isEmpty) return null;
    return r.first['id_visitante'] as int;
  }

  /// R2 — Retorna visitantes frecuentes del empleado (agenda de confianza).
  Future<List<Map<String, dynamic>>> visitantesFrecuentes(int idEmpleado) async {
    final db = await _local.db;
    return db.rawQuery('''
      SELECT v.id_visitante, v.nombre, v.apellidos, v.correo_personal
      FROM visitante v
      JOIN empleado_visitante ev ON ev.id_visitante = v.id_visitante
      WHERE ev.id_empleado = ?
      ORDER BY ev.fecha_vinculo DESC
      LIMIT 20
    ''', [idEmpleado]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SOLICITUDES — AUTORIZADOR
  // ══════════════════════════════════════════════════════════════════════════

  /// Obtiene solicitudes pendientes del autorizador autenticado.
  /// También expira automáticamente las solicitudes vencidas (R5).
  Future<List<SolicitudModel>> obtenerPendientes() async {
    final db     = await _local.db;
    final idAuth = await _sess.leerEmpleadoId() ?? 0;

    // R5: Expirar solicitudes cuya fecha_inicio ya pasó
    await _expirarSolicitudesVencidas(db);

    final rows = await db.rawQuery('''
      SELECT s.*,
        es.nombre AS nombre_estado,
        ts.nombre AS nombre_tipo
      FROM solicitud s
      JOIN ca_estado_solicitud es ON es.id_estado = s.id_estado_solicitud
      JOIN ca_tipo_solicitud   ts ON ts.id_tipo_solicitud = s.id_tipo_solicitud
      WHERE (s.id_autorizador = ? OR s.id_autorizador_alt = ?)
        AND s.id_estado_solicitud = 1
      ORDER BY s.fecha_inicio ASC
    ''', [idAuth, idAuth]);

    return _filasSolicitudAModelo(db, rows);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SOLICITUDES — SOLICITANTE
  // ══════════════════════════════════════════════════════════════════════════

  /// Obtiene todas las solicitudes de un empleado (solicitante).
  Future<List<SolicitudModel>> obtenerMisSolicitudes(int idEmpleado) async {
    final db = await _local.db;
    await _expirarSolicitudesVencidas(db);

    final rows = await db.rawQuery('''
      SELECT s.*,
        es.nombre AS nombre_estado,
        ts.nombre AS nombre_tipo
      FROM solicitud s
      JOIN ca_estado_solicitud es ON es.id_estado = s.id_estado_solicitud
      JOIN ca_tipo_solicitud   ts ON ts.id_tipo_solicitud = s.id_tipo_solicitud
      WHERE s.id_solicitante = ?
      ORDER BY s.fecha_creacion DESC
    ''', [idEmpleado]);

    return _filasSolicitudAModelo(db, rows);
  }

  /// Crea solicitud completa: inserta solicitud, visitantes, pivot y QRs.
  /// Aplica reglas R1 (unicidad), R2 (agenda), R3 (veto), R8 (vigencias QR).
  Future<SolicitudModel> crearSolicitud({
    required DateTime fechaInicio,
    required int toleranciaAntes,
    required int toleranciaDespues,
    required String lugarEncuentro,
    required String motivoVisita,
    required int idTipoSolicitud,
    required int idAutorizador,
    int? idAutorizadorAlt,
    required int idSolicitante,
    required List<Map<String, String>> visitantes,
  }) async {
    if (visitantes.isEmpty) {
      throw const ValidationException('Debes agregar al menos un visitante.');
    }

    final db = await _local.db;

    return db.transaction((txn) async {
      // ── Insertar solicitud ────────────────────────────────────────────────
      final idSolicitud = await txn.insert('solicitud', {
        'fecha_inicio':        fechaInicio.toIso8601String(),
        'tolerancia_antes':    toleranciaAntes,
        'tolerancia_despues':  toleranciaDespues,
        'lugar_encuentro':     lugarEncuentro,
        'motivo_visita':       motivoVisita,
        'id_tipo_solicitud':   idTipoSolicitud,
        'id_autorizador':      idAutorizador,
        'id_autorizador_alt':  idAutorizadorAlt,
        'id_solicitante':      idSolicitante,
        'id_estado_solicitud': 1, // pendiente
      });

      // ── Procesar cada visitante ───────────────────────────────────────────
      for (final v in visitantes) {
        final correo = (v['correo'] ?? '').trim().toLowerCase();
        if (correo.isEmpty) {
          throw const ValidationException('El correo del visitante es obligatorio.');
        }

        // R3: Verificar veto ANTES de crear
        final idExistente = await _buscarVisitanteEnTxn(txn, correo);
        if (idExistente != null) {
          final vetado = await _estaVetadoEnTxn(txn, idExistente);
          if (vetado) {
            throw VetoException(
              'El visitante $correo tiene acceso restringido al plantel.',
            );
          }
        }

        // R1: Upsert — reutiliza visitante si ya existe con ese correo
        final idVis = await _upsertVisitanteEnTxn(
          txn,
          nombre:    (v['nombre']    ?? 'Visitante').trim(),
          apellidos: (v['apellidos'] ?? '').trim(),
          correo:    correo,
        );

        // R2: Registrar en agenda de confianza del empleado
        await txn.insert(
          'empleado_visitante',
          {'id_visitante': idVis, 'id_empleado': idSolicitante},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );

        // Pivot solicitud ↔ visitante
        final idSV = await txn.insert('solicitud_visitante', {
          'id_visitante': idVis,
          'id_solicitud': idSolicitud,
        });

        // R8: Calcular vigencias del QR
        // vigencia_inicio = fecha_inicio - tolerancia_antes minutos
        // vigencia_final  = fecha_inicio + tolerancia_despues minutos
        final vigenciaInicio = fechaInicio.subtract(
          Duration(minutes: toleranciaAntes),
        );
        final vigenciaFinal = fechaInicio.add(
          Duration(minutes: toleranciaDespues),
        );
        final codigo = _generarCodigoQr(idSolicitud, idVis);

        await txn.insert('qr', {
          'codigo_numerico':        codigo,
          'vigencia_inicio':        vigenciaInicio.toIso8601String(),
          'vigencia_final':         vigenciaFinal.toIso8601String(),
          'id_estado_qr':           1, // activo
          'id_solicitud_visitante': idSV,
        });

        AppLogger.info('SolicitudRepositorioLocal',
            'QR generado: $codigo para visitante $correo');
      }

      // ── Notificaciones para autorizadores ────────────────────────────────
      await txn.insert('notificacion', {
        'id_empleado': idAutorizador,
        'id_solicitud': idSolicitud,
        'tipo': 'SOLICITUD_NUEVA',
        'mensaje': 'Tienes una nueva solicitud de visita pendiente de aprobar.',
      });
      if (idAutorizadorAlt != null && idAutorizadorAlt != idAutorizador) {
        await txn.insert('notificacion', {
          'id_empleado': idAutorizadorAlt,
          'id_solicitud': idSolicitud,
          'tipo': 'SOLICITUD_NUEVA',
          'mensaje': 'Tienes una nueva solicitud de visita pendiente de aprobar.',
        });
      }

      // ── Bitácora ─────────────────────────────────────────────────────────
      await txn.insert('bitacora', {
        'id_empleado': idSolicitante,
        'accion':      'CREAR_SOLICITUD',
        'modulo':      'solicitante',
        'detalle':     '{"idSolicitud":$idSolicitud}',
      });

      // ── Retornar el modelo recién creado ─────────────────────────────────
      final rowSolicitud = await txn.query(
        'solicitud',
        where: 'id_solicitud = ?',
        whereArgs: [idSolicitud],
        limit: 1,
      );
      final visitantesGuardados =
          await _obtenerVisitantesEnTxn(txn, idSolicitud);

      return _mapearSolicitud(
        {
          ...rowSolicitud.first,
          'nombre_estado': 'pendiente',
          'nombre_tipo': 'agendada_personal',
        },
        visitantesGuardados,
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACCIONES DEL AUTORIZADOR
  // ══════════════════════════════════════════════════════════════════════════

  /// Aprueba una solicitud. R4: falla si ya fue procesada por otro.
  Future<void> aprobar(int idSolicitud) async {
    final db    = await _local.db;
    final idEmp = await _sess.leerEmpleadoId() ?? 0;

    await db.transaction((txn) async {
      final s = await txn.query(
        'solicitud',
        where: 'id_solicitud = ?',
        whereArgs: [idSolicitud],
        limit: 1,
      );
      if (s.isEmpty) {
        throw const NoEncontradoException('Solicitud no encontrada.');
      }
      if ((s.first['id_estado_solicitud'] as int) != 1) {
        throw const ConcurrenciaException(
            'Esta solicitud ya fue procesada por otro autorizador.');
      }

      await txn.update(
        'solicitud',
        {'id_estado_solicitud': 2}, // aprobada
        where: 'id_solicitud = ?',
        whereArgs: [idSolicitud],
      );

      // Notificar al solicitante
      final idSolicitante = s.first['id_solicitante'] as int;
      await txn.insert('notificacion', {
        'id_empleado':  idSolicitante,
        'id_solicitud': idSolicitud,
        'tipo':         'SOLICITUD_APROBADA',
        'mensaje':
            'Tu solicitud fue aprobada. Ya puedes enviar el QR a tu visitante.',
      });

      await txn.insert('bitacora', {
        'id_empleado': idEmp,
        'accion':      'APROBAR_SOLICITUD',
        'modulo':      'autorizador',
        'detalle':     '{"idSolicitud":$idSolicitud}',
      });
    });

    AppLogger.accionUsuario('Solicitud aprobada', contexto: {'id': idSolicitud});
  }

  /// Rechaza una solicitud.
  Future<void> rechazar(int idSolicitud, {String? motivo}) async {
    final db    = await _local.db;
    final idEmp = await _sess.leerEmpleadoId() ?? 0;

    await db.transaction((txn) async {
      final s = await txn.query(
        'solicitud',
        where: 'id_solicitud = ?',
        whereArgs: [idSolicitud],
        limit: 1,
      );
      if (s.isEmpty) {
        throw const NoEncontradoException('Solicitud no encontrada.');
      }
      if ((s.first['id_estado_solicitud'] as int) != 1) {
        throw const ConcurrenciaException('Esta solicitud ya fue procesada.');
      }

      await txn.update(
        'solicitud',
        {'id_estado_solicitud': 3}, // rechazada
        where: 'id_solicitud = ?',
        whereArgs: [idSolicitud],
      );

      final idSolicitante = s.first['id_solicitante'] as int;
      await txn.insert('notificacion', {
        'id_empleado':  idSolicitante,
        'id_solicitud': idSolicitud,
        'tipo':         'SOLICITUD_RECHAZADA',
        'mensaje':      motivo ?? 'Tu solicitud de visita fue rechazada.',
      });

      await txn.insert('bitacora', {
        'id_empleado': idEmp,
        'accion':      'RECHAZAR_SOLICITUD',
        'modulo':      'autorizador',
        'detalle':     '{"idSolicitud":$idSolicitud}',
      });
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACCIONES DEL SOLICITANTE
  // ══════════════════════════════════════════════════════════════════════════

  /// Cancela una solicitud y sus QRs activos (R12).
  Future<void> cancelar(int idSolicitud) async {
    final db    = await _local.db;
    final idEmp = await _sess.leerEmpleadoId() ?? 0;

    await db.transaction((txn) async {
      await txn.update(
        'solicitud',
        {'id_estado_solicitud': 4}, // cancelada
        where: 'id_solicitud = ?',
        whereArgs: [idSolicitud],
      );

      // Cancelar QRs activos (estado 1 = activo → 5 = cancelado)
      await txn.rawUpdate('''
        UPDATE qr SET id_estado_qr = 5
        WHERE id_solicitud_visitante IN (
          SELECT id_solicitud_visitante
          FROM solicitud_visitante
          WHERE id_solicitud = ?
        ) AND id_estado_qr = 1
      ''', [idSolicitud]);

      await txn.insert('bitacora', {
        'id_empleado': idEmp,
        'accion':      'CANCELAR_SOLICITUD',
        'modulo':      'solicitante',
        'detalle':     '{"idSolicitud":$idSolicitud}',
      });
    });
  }

  /// Retorna los datos del QR de una solicitud aprobada para mostrar al solicitante.
  /// El solicitante puede copiar/mostrar el código a su visitante.
  Future<List<Map<String, dynamic>>> obtenerQrsDeSolicitud(int idSolicitud) async {
    final db = await _local.db;
    return db.rawQuery('''
      SELECT
        q.id_qr,
        q.codigo_numerico,
        q.vigencia_inicio,
        q.vigencia_final,
        eq.nombre AS estado_qr,
        v.nombre  AS nombre_visitante,
        v.apellidos AS apellidos_visitante,
        v.correo_personal
      FROM solicitud_visitante sv
      JOIN qr           q  ON q.id_solicitud_visitante = sv.id_solicitud_visitante
      JOIN ca_estado_qr eq ON eq.id_estado_qr = q.id_estado_qr
      JOIN visitante    v  ON v.id_visitante = sv.id_visitante
      WHERE sv.id_solicitud = ?
    ''', [idSolicitud]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ESCANEO QR — VIGILANTE
  // ══════════════════════════════════════════════════════════════════════════

  /// Procesa el escaneo de un QR por el vigilante.
  /// Retorna un mapa con 'estado' y datos del visitante.
  /// Implementa: R3 (veto), R6 (ciclo de vida QR), R7 (prórroga), R10 (notificación).
  Future<Map<String, dynamic>> escanearQr({
    required String codigoQr,
    required int idVigilante,
  }) async {
    final db    = await _local.db;
    final ahora = DateTime.now();

    // ── Buscar el QR con todos sus datos relacionados ─────────────────────
    final qrRows = await db.rawQuery('''
      SELECT
        q.id_qr,
        q.codigo_numerico,
        q.vigencia_inicio,
        q.vigencia_final,
        q.prorroga_tolerancia,
        q.id_estado_qr,
        eq.nombre  AS nombre_estado_qr,
        v.id_visitante,
        v.nombre   AS nombre_visitante,
        v.apellidos AS apellidos_visitante,
        v.correo_personal,
        s.id_solicitante,
        s.lugar_encuentro,
        s.tolerancia_antes,
        s.tolerancia_despues,
        s.prorroga_toleran
      FROM qr q
      JOIN ca_estado_qr        eq ON eq.id_estado_qr = q.id_estado_qr
      JOIN solicitud_visitante  sv ON sv.id_solicitud_visitante = q.id_solicitud_visitante
      JOIN visitante             v  ON v.id_visitante = sv.id_visitante
      JOIN solicitud             s  ON s.id_solicitud = sv.id_solicitud
      WHERE q.codigo_numerico = ?
      LIMIT 1
    ''', [codigoQr]);

    if (qrRows.isEmpty) {
      return {
        'estado':     'NO_ENCONTRADO',
        'mensaje':    'Código QR no encontrado en el sistema.',
        'horaActual': ahora.toIso8601String(),
      };
    }

    final qr        = qrRows.first;
    final idQr      = qr['id_qr']            as int;
    final estadoQr  = qr['nombre_estado_qr'] as String;
    final vigInicio = DateTime.parse(qr['vigencia_inicio'] as String);
    final vigFin    = DateTime.parse(qr['vigencia_final']  as String);
    final idVisit   = qr['id_visitante']      as int;
    final nombre    = '${qr["nombre_visitante"]} ${qr["apellidos_visitante"]}';
    final correo    = qr['correo_personal']   as String;

    // R3: Verificar veto ──────────────────────────────────────────────────
    if (await estaVetado(idVisit)) {
      return {
        'estado':          'EN_LISTA_EXCLUSION',
        'mensaje':         'ACCESO DENEGADO. Este visitante tiene restricción de acceso al plantel.',
        'nombreVisitante': nombre,
        'horaActual':      ahora.toIso8601String(),
      };
    }

    // R6: Ciclo de vida — estado cancelado ───────────────────────────────
    if (estadoQr == 'cancelado') {
      return {
        'estado':  'CANCELADO',
        'mensaje': 'Este acceso fue cancelado por el anfitrión o por el sistema.',
        'horaActual': ahora.toIso8601String(),
      };
    }

    // R6: Ya completó ciclo completo ─────────────────────────────────────
    if (estadoQr == 'usado_salida') {
      return {
        'estado':          'YA_UTILIZADO',
        'mensaje':         'Este QR ya registró entrada y salida. El ciclo está completo.',
        'nombreVisitante': nombre,
        'horaActual':      ahora.toIso8601String(),
      };
    }

    // R7: QR vencido — ofrecer prórroga si el empleado lo configuró ────────
    final estaVencido = ahora.isAfter(vigFin) && estadoQr != 'extendido';
    if (estaVencido) {
      final permiteProrroga = (qr['prorroga_toleran'] as int? ?? 0) == 1;
      return {
        'estado':           'VENCIDO',
        'mensaje':          permiteProrroga
            ? 'QR vencido. Puedes solicitar prórroga al anfitrión (1 minuto de espera).'
            : 'QR vencido. El anfitrión no habilitó prórroga. Solicita un nuevo acceso.',
        'permiteProrroga':  permiteProrroga,
        'idQr':             idQr,
        'nombreVisitante':  nombre,
        'correoVisitante':  correo,
        'lugarEncuentro':   qr['lugar_encuentro'] ?? '',
        'horaActual':       ahora.toIso8601String(),
      };
    }

    // Aún anticipado — no ha llegado la hora ────────────────────────────
    if (ahora.isBefore(vigInicio)) {
      final minutosRestantes = vigInicio.difference(ahora).inMinutes;
      return {
        'estado':          'ANTICIPADO',
        'mensaje':         'Aún no es la hora de entrada. Faltan $minutosRestantes min.',
        'nombreVisitante': nombre,
        'horaActual':      ahora.toIso8601String(),
      };
    }

    // R6: Registrar ENTRADA ─────────────────────────────────────────────
    if (estadoQr == 'activo' || estadoQr == 'extendido') {
      await db.transaction((txn) async {
        // Cambiar estado QR a "usado_entrada" (id=2)
        await txn.update(
          'qr',
          {'id_estado_qr': 2},
          where: 'id_qr = ?',
          whereArgs: [idQr],
        );

        // Crear registro de acceso
        await txn.insert(
          'registro_acceso',
          {
            'hora_llegada_institucion': ahora.toIso8601String(),
            'id_vigilante_entrada':     idVigilante,
            'id_qr':                    idQr,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // R10: Notificar al anfitrión que su visitante entró
        await txn.insert('notificacion', {
          'id_empleado':  qr['id_solicitante'],
          'id_solicitud': null,
          'tipo':         'VISITANTE_ENTRO',
          'mensaje':
              'Tu visitante $nombre entró al plantel a las ${_formatHora(ahora)}.',
        });

        await txn.insert('bitacora', {
          'id_empleado': idVigilante,
          'accion':      'REGISTRAR_ENTRADA',
          'modulo':      'vigilante',
          'detalle':     '{"idQr":$idQr,"codigo":"$codigoQr"}',
        });
      });

      return {
        'estado':          'VALIDO_ENTRADA',
        'mensaje':         '✓ Entrada registrada. Bienvenido.',
        'idQr':            idQr,
        'codigoQr':        codigoQr,
        'nombreVisitante': nombre,
        'correoVisitante': correo,
        'lugarEncuentro':  qr['lugar_encuentro'] ?? '',
        'horaActual':      ahora.toIso8601String(),
      };
    }

    // R6: Registrar SALIDA ──────────────────────────────────────────────
    if (estadoQr == 'usado_entrada') {
      await db.transaction((txn) async {
        // Cambiar estado QR a "usado_salida" (id=3)
        await txn.update(
          'qr',
          {'id_estado_qr': 3},
          where: 'id_qr = ?',
          whereArgs: [idQr],
        );

        // Actualizar registro de acceso con hora de salida
        await txn.update(
          'registro_acceso',
          {
            'hora_salida_institucion': ahora.toIso8601String(),
            'id_vigilante_salida':     idVigilante,
          },
          where: 'id_qr = ?',
          whereArgs: [idQr],
        );

        await txn.insert('bitacora', {
          'id_empleado': idVigilante,
          'accion':      'REGISTRAR_SALIDA',
          'modulo':      'vigilante',
          'detalle':     '{"idQr":$idQr}',
        });
      });

      return {
        'estado':          'VALIDO_SALIDA',
        'mensaje':         '✓ Salida registrada. Hasta pronto.',
        'idQr':            idQr,
        'nombreVisitante': nombre,
        'horaActual':      ahora.toIso8601String(),
      };
    }

    return {
      'estado':     'DESCONOCIDO',
      'mensaje':    'Estado del QR no reconocido. Contacta a soporte.',
      'horaActual': ahora.toIso8601String(),
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRÓRROGA (R7)
  // ══════════════════════════════════════════════════════════════════════════

  /// El autorizador aprueba la prórroga: extiende vigencia_final del QR.
  Future<void> autorizarProrroga(int idQr) async {
    final db    = await _local.db;
    final idEmp = await _sess.leerEmpleadoId() ?? 0;

    await db.transaction((txn) async {
      final qrRow = await txn.query(
        'qr',
        where: 'id_qr = ?',
        whereArgs: [idQr],
        limit: 1,
      );
      if (qrRow.isEmpty) {
        throw const NoEncontradoException('QR no encontrado para prorrogar.');
      }

      // Obtener tolerancia_despues de la solicitud
      final tolRows = await txn.rawQuery('''
        SELECT s.tolerancia_despues
        FROM solicitud s
        JOIN solicitud_visitante sv ON sv.id_solicitud = s.id_solicitud
        WHERE sv.id_solicitud_visitante = ?
        LIMIT 1
      ''', [qrRow.first['id_solicitud_visitante']]);

      final mins = tolRows.isNotEmpty
          ? (tolRows.first['tolerancia_despues'] as int? ?? 15)
          : 15;

      final nuevaFin = DateTime.now().add(Duration(minutes: mins));

      // Cambiar estado a "extendido" (id=6) y actualizar vigencia_final
      await txn.update(
        'qr',
        {
          'vigencia_final':     nuevaFin.toIso8601String(),
          'prorroga_tolerancia': 1,
          'id_estado_qr':       6, // extendido
        },
        where: 'id_qr = ?',
        whereArgs: [idQr],
      );

      await txn.insert('bitacora', {
        'id_empleado': idEmp,
        'accion':      'PRORROGA_APROBADA',
        'modulo':      'autorizador',
        'detalle':     '{"idQr":$idQr,"extensionMin":$mins}',
      });
    });

    AppLogger.accionUsuario('Prórroga autorizada', contexto: {'idQr': idQr});
  }

  /// Polling del estado actual de un QR (usado por el vigilante para saber
  /// si el autorizador aprobó la prórroga).
  /// Retorna el nombre del estado: 'extendido', 'vencido', 'activo', etc.
  Future<String> consultarEstadoQr(int idQr) async {
    final db = await _local.db;
    final r = await db.rawQuery('''
      SELECT eq.nombre AS estado_qr
      FROM qr q
      JOIN ca_estado_qr eq ON eq.id_estado_qr = q.id_estado_qr
      WHERE q.id_qr = ?
      LIMIT 1
    ''', [idQr]);

    if (r.isEmpty) return 'no_encontrado';
    return r.first['estado_qr'] as String? ?? 'desconocido';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VISITA ESPONTÁNEA (R11)
  // ══════════════════════════════════════════════════════════════════════════

  /// El vigilante registra una visita espontánea sin solicitud previa.
  /// Genera un QR temporal válido hasta el fin del día.
  Future<Map<String, dynamic>> registrarVisitaEspontanea({
    required String nombre,
    required String correo,
    required int    idDepartamento,
    required int    idVigilante,
  }) async {
    final db    = await _local.db;
    final ahora = DateTime.now();

    return db.transaction((txn) async {
      // R1: Buscar visitante existente por correo
      final existente = await txn.query(
        'visitante',
        where: 'correo_personal = ?',
        whereArgs: [correo.trim().toLowerCase()],
        limit: 1,
      );

      int idVisitante;
      if (existente.isNotEmpty) {
        idVisitante = existente.first['id_visitante'] as int;
      } else {
        idVisitante = await txn.insert('visitante', {
          'nombre':          nombre.trim().isEmpty ? 'Visitante' : nombre.trim(),
          'apellidos':       '',
          'correo_personal': correo.trim().toLowerCase(),
        });
      }

      // R3: Verificar veto
      final vetado = await txn.query(
        'lista_exclusion',
        where: 'id_visitante = ?',
        whereArgs: [idVisitante],
        limit: 1,
      );
      if (vetado.isNotEmpty) {
        throw const VetoException(
          'Este visitante tiene acceso restringido al plantel.',
        );
      }

      // Crear solicitud de tipo "espontanea" (id=3)
      // La solicitud va al departamento destino, sin autorizador específico
      final idSolicitud = await txn.insert('solicitud', {
        'fecha_inicio':        ahora.toIso8601String(),
        'tolerancia_antes':    0,
        'tolerancia_despues':  0,
        'lugar_encuentro':     'Departamento $idDepartamento',
        'motivo_visita':       'Visita espontánea / Consulta de información',
        'id_tipo_solicitud':   3, // espontanea
        'id_autorizador':      idDepartamento, // el departamento "autoriza" al recibirlo
        'id_solicitante':      idVigilante,
        'id_estado_solicitud': 2, // aprobada directamente
      });

      // Crear pivot
      final idSV = await txn.insert('solicitud_visitante', {
        'id_visitante': idVisitante,
        'id_solicitud': idSolicitud,
      });

      // QR temporal válido hasta fin del día
      final finDelDia = DateTime(ahora.year, ahora.month, ahora.day, 22, 0, 0);
      final codigo    = 'ESP-${ahora.millisecondsSinceEpoch}-${idVisitante.toString().padLeft(4, '0')}';

      final idQr = await txn.insert('qr', {
        'codigo_numerico':        codigo,
        'vigencia_inicio':        ahora.toIso8601String(),
        'vigencia_final':         finDelDia.toIso8601String(),
        'id_estado_qr':           1, // activo
        'id_solicitud_visitante': idSV,
      });

      // Notificar al departamento destino
      await txn.insert('notificacion', {
        'id_empleado':  idDepartamento,
        'id_solicitud': idSolicitud,
        'tipo':         'VISITA_ESPONTANEA',
        'mensaje':
            'Viene alguien a consultar a tu departamento. Código QR: $codigo',
      });

      await txn.insert('bitacora', {
        'id_empleado': idVigilante,
        'accion':      'VISITA_ESPONTANEA',
        'modulo':      'vigilante',
        'detalle':     '{"idVisitante":$idVisitante,"idQr":$idQr,"correo":"$correo"}',
      });

      AppLogger.accionUsuario('Visita espontánea registrada',
          contexto: {'correo': correo, 'codigo': codigo});

      return {
        'idQr':      idQr,
        'codigoQr':  codigo,
        'idVisitante': idVisitante,
        'mensaje':
            'QR generado. El visitante puede presentar el código: $codigo',
        'vigenciaHasta': finDelDia.toIso8601String(),
      };
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VISITAS DEL DÍA (VIGILANTE)
  // ══════════════════════════════════════════════════════════════════════════

  /// Retorna visitas aprobadas para hoy, con estado del QR.
  Future<List<Map<String, dynamic>>> visitasHoy() async {
    final db  = await _local.db;
    final hoy = DateTime.now();
    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day).toIso8601String();
    final finDia    = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59).toIso8601String();

    return db.rawQuery('''
      SELECT
        s.id_solicitud,
        s.fecha_inicio,
        s.lugar_encuentro,
        es.nombre AS estado_solicitud,
        v.id_visitante,
        v.nombre   AS nombre_visitante,
        v.apellidos AS apellidos_visitante,
        v.correo_personal,
        q.id_qr,
        q.codigo_numerico,
        eq.nombre  AS estado_qr,
        ra.hora_llegada_institucion,
        ra.hora_salida_institucion
      FROM solicitud s
      JOIN ca_estado_solicitud es ON es.id_estado = s.id_estado_solicitud
      JOIN solicitud_visitante  sv ON sv.id_solicitud = s.id_solicitud
      JOIN visitante             v  ON v.id_visitante = sv.id_visitante
      JOIN qr                    q  ON q.id_solicitud_visitante = sv.id_solicitud_visitante
      JOIN ca_estado_qr          eq ON eq.id_estado_qr = q.id_estado_qr
      LEFT JOIN registro_acceso  ra ON ra.id_qr = q.id_qr
      WHERE s.fecha_inicio BETWEEN ? AND ?
        AND s.id_estado_solicitud IN (2)
      ORDER BY s.fecha_inicio ASC
    ''', [inicioDia, finDia]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICACIONES
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> notificaciones(int idEmpleado) async {
    final db = await _local.db;
    return db.query(
      'notificacion',
      where: 'id_empleado = ?',
      whereArgs: [idEmpleado],
      orderBy: 'fecha_creado DESC',
      limit: 50,
    );
  }

  Future<void> marcarNotificacionLeida(int idNotificacion) async {
    final db = await _local.db;
    await db.update(
      'notificacion',
      {'leida': 1},
      where: 'id_notificacion = ?',
      whereArgs: [idNotificacion],
    );
  }

  Future<int> contarNoLeidas(int idEmpleado) async {
    final db = await _local.db;
    final r = await db.rawQuery('''
      SELECT COUNT(*) as total
      FROM notificacion
      WHERE id_empleado = ? AND leida = 0
    ''', [idEmpleado]);
    return r.first['total'] as int? ?? 0;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS PRIVADOS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _expirarSolicitudesVencidas(Database db) async {
    final ahora = DateTime.now().toIso8601String();
    // Solo expirar las que ya pasaron su fecha_inicio completa
    await db.rawUpdate('''
      UPDATE solicitud
      SET id_estado_solicitud = 5
      WHERE id_estado_solicitud = 1
        AND fecha_inicio < ?
    ''', [ahora]);
  }

  Future<int> _upsertVisitanteEnTxn(
    Transaction txn, {
    required String nombre,
    required String apellidos,
    required String correo,
  }) async {
    final r = await txn.query(
      'visitante',
      where: 'correo_personal = ?',
      whereArgs: [correo],
      limit: 1,
    );
    if (r.isNotEmpty) return r.first['id_visitante'] as int;
    return txn.insert('visitante', {
      'nombre':          nombre.isEmpty ? 'Visitante' : nombre,
      'apellidos':       apellidos,
      'correo_personal': correo,
    });
  }

  Future<int?> _buscarVisitanteEnTxn(Transaction txn, String correo) async {
    final r = await txn.query(
      'visitante',
      where: 'correo_personal = ?',
      whereArgs: [correo],
      limit: 1,
    );
    if (r.isEmpty) return null;
    return r.first['id_visitante'] as int;
  }

  Future<bool> _estaVetadoEnTxn(Transaction txn, int idVisitante) async {
    final r = await txn.query(
      'lista_exclusion',
      where: 'id_visitante = ?',
      whereArgs: [idVisitante],
      limit: 1,
    );
    return r.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> _obtenerVisitantesDesolicitud(
    Database db,
    int idSolicitud,
  ) async {
    return db.rawQuery('''
      SELECT
        v.id_visitante, v.nombre, v.apellidos, v.correo_personal,
        q.id_qr, q.codigo_numerico,
        eq.nombre AS estado_qr
      FROM solicitud_visitante sv
      JOIN visitante    v  ON v.id_visitante = sv.id_visitante
      LEFT JOIN qr      q  ON q.id_solicitud_visitante = sv.id_solicitud_visitante
      LEFT JOIN ca_estado_qr eq ON eq.id_estado_qr = q.id_estado_qr
      WHERE sv.id_solicitud = ?
    ''', [idSolicitud]);
  }

  Future<List<Map<String, dynamic>>> _obtenerVisitantesEnTxn(
    Transaction txn,
    int idSolicitud,
  ) async {
    return txn.rawQuery('''
      SELECT v.id_visitante, v.nombre, v.apellidos, v.correo_personal
      FROM solicitud_visitante sv
      JOIN visitante v ON v.id_visitante = sv.id_visitante
      WHERE sv.id_solicitud = ?
    ''', [idSolicitud]);
  }

  Future<List<SolicitudModel>> _filasSolicitudAModelo(
    Database db,
    List<Map<String, dynamic>> rows,
  ) async {
    final result = <SolicitudModel>[];
    for (final row in rows) {
      final idSol     = row['id_solicitud'] as int;
      final visitantes = await _obtenerVisitantesDesolicitud(db, idSol);
      result.add(_mapearSolicitud(row, visitantes));
    }
    return result;
  }

  SolicitudModel _mapearSolicitud(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> visitantesRows,
  ) {
    final visitantes = visitantesRows.map((v) => VisitanteModel(
      idVisitante:    v['id_visitante']    as int?    ?? 0,
      nombre:         v['nombre']          as String? ?? '',
      apellidos:      v['apellidos']       as String? ?? '',
      correoPersonal: v['correo_personal'] as String? ?? '',
    )).toList();

    return SolicitudModel(
      idSolicitud:             row['id_solicitud']         as int?    ?? 0,
      fechaInicio:             row['fecha_inicio']          as String? ?? '',
      toleranciaAntes:         row['tolerancia_antes']      as int?    ?? 15,
      toleranciaDespues:       row['tolerancia_despues']    as int?    ?? 15,
      // CORRECCIÓN: campo correcto del modelo
      prorrogaTolerancia:      (row['prorroga_toleran'] as int? ?? 0) == 1,
      observaciones:           row['observaciones']         as String? ?? '',
      fechaCreacion:           row['fecha_creacion']        as String? ?? '',
      estado:                  row['nombre_estado']         as String? ?? '',
      tipoSolicitud:           row['nombre_tipo']           as String? ?? '',
      lugarEncuentro:          row['lugar_encuentro']       as String? ?? '',
      motivoVisita:            row['motivo_visita']         as String? ?? '',
      idSolicitante:           row['id_solicitante']        as int?    ?? 0,
      nombreSolicitante:       '',
      departamentoSolicitante: '',
      correoSolicitante:       '',
      idAutorizador:           row['id_autorizador']        as int?    ?? 0,
      nombreAutorizador:       '',
      visitantes:              visitantes,
    );
  }

  /// Genera un código QR único con formato: VIS-{timestamp}-{idSolicitud}-{random}
  String _generarCodigoQr(int idSolicitud, int idVisitante) {
    final ts  = DateTime.now().millisecondsSinceEpoch;
    final rnd = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'VIS-$ts-${idSolicitud.toString().padLeft(4, '0')}-$rnd';
  }

  String _formatHora(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
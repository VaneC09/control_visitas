// local_database.dart
// Crea y gestiona la BD SQLite local en el dispositivo.
// Misma estructura que MySQL para poder sincronizar después.
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instancia = LocalDatabase._internal();
  LocalDatabase._internal();

  static Database? _db;

  Future<Database> get db async {
    _db ??= await _inicializar();
    return _db!;
  }

  Future<Database> _inicializar() async {
    final ruta = join(await getDatabasesPath(), 'omega_local.db');
    return openDatabase(
      ruta,
      version: 1,
      onCreate: _crearTablas,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ca_estado_solicitud (
        id_estado INTEGER PRIMARY KEY,
        nombre    TEXT NOT NULL UNIQUE,
        color_hex TEXT NOT NULL DEFAULT '#595959'
      )
    ''');
    await db.insert('ca_estado_solicitud',
        {'id_estado':1,'nombre':'pendiente','color_hex':'#856404'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('ca_estado_solicitud',
        {'id_estado':2,'nombre':'aprobada','color_hex':'#065F46'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('ca_estado_solicitud',
        {'id_estado':3,'nombre':'rechazada','color_hex':'#991B1B'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('ca_estado_solicitud',
        {'id_estado':4,'nombre':'cancelada','color_hex':'#595959'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('ca_estado_solicitud',
        {'id_estado':5,'nombre':'expirada','color_hex':'#7C3AED'},
        conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ca_tipo_solicitud (
        id_tipo_solicitud INTEGER PRIMARY KEY,
        nombre            TEXT NOT NULL UNIQUE
      )
    ''');
    await db.insert('ca_tipo_solicitud',
        {'id_tipo_solicitud':1,'nombre':'agendada_personal'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('ca_tipo_solicitud',
        {'id_tipo_solicitud':2,'nombre':'agendada_proveedor'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('ca_tipo_solicitud',
        {'id_tipo_solicitud':3,'nombre':'espontanea'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('ca_tipo_solicitud',
        {'id_tipo_solicitud':4,'nombre':'grupal'},
        conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ca_estado_qr (
        id_estado_qr INTEGER PRIMARY KEY,
        nombre       TEXT NOT NULL UNIQUE
      )
    ''');
    for(final e in [
      {'id_estado_qr':1,'nombre':'activo'},
      {'id_estado_qr':2,'nombre':'usado_entrada'},
      {'id_estado_qr':3,'nombre':'usado_salida'},
      {'id_estado_qr':4,'nombre':'vencido'},
      {'id_estado_qr':5,'nombre':'cancelado'},
      {'id_estado_qr':6,'nombre':'extendido'},
    ]) {
      await db.insert('ca_estado_qr', e,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await db.execute('''
      CREATE TABLE IF NOT EXISTS visitante (
        id_visitante    INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre          TEXT NOT NULL,
        apellidos       TEXT NOT NULL,
        correo_personal TEXT NOT NULL UNIQUE,
        foto_url        TEXT,
        fecha_registro  TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS empleado_visitante (
        id_lista_visitante INTEGER PRIMARY KEY AUTOINCREMENT,
        id_visitante       INTEGER NOT NULL,
        id_empleado        INTEGER NOT NULL,
        fecha_vinculo      TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (id_visitante) REFERENCES visitante(id_visitante)
          ON DELETE CASCADE,
        UNIQUE (id_visitante, id_empleado)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS lista_exclusion (
        id_lista_exclusion INTEGER PRIMARY KEY AUTOINCREMENT,
        motivo_exclusion   TEXT NOT NULL,
        id_visitante       INTEGER NOT NULL UNIQUE,
        id_autorizador     INTEGER NOT NULL,
        fecha_bloqueo      TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (id_visitante) REFERENCES visitante(id_visitante)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS solicitud (
        id_solicitud        INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha_inicio        TEXT NOT NULL,
        tolerancia_antes    INTEGER NOT NULL DEFAULT 15,
        tolerancia_despues  INTEGER NOT NULL DEFAULT 15,
        prorroga_toleran    INTEGER NOT NULL DEFAULT 0,
        lugar_encuentro     TEXT,
        motivo_visita       TEXT,
        observaciones       TEXT,
        fecha_creacion      TEXT DEFAULT (datetime('now')),
        fecha_expiracion    TEXT,
        id_estado_solicitud INTEGER NOT NULL DEFAULT 1,
        id_tipo_solicitud   INTEGER NOT NULL,
        id_autorizador      INTEGER,
        id_autorizador_alt  INTEGER,
        id_solicitante      INTEGER NOT NULL,
        FOREIGN KEY (id_estado_solicitud)
          REFERENCES ca_estado_solicitud(id_estado),
        FOREIGN KEY (id_tipo_solicitud)
          REFERENCES ca_tipo_solicitud(id_tipo_solicitud)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS solicitud_visitante (
        id_solicitud_visitante INTEGER PRIMARY KEY AUTOINCREMENT,
        id_visitante           INTEGER NOT NULL,
        id_solicitud           INTEGER NOT NULL,
        FOREIGN KEY (id_visitante) REFERENCES visitante(id_visitante)
          ON DELETE CASCADE,
        FOREIGN KEY (id_solicitud) REFERENCES solicitud(id_solicitud)
          ON DELETE CASCADE,
        UNIQUE (id_visitante, id_solicitud)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS qr (
        id_qr                  INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo_numerico        TEXT NOT NULL UNIQUE,
        fecha_generacion       TEXT DEFAULT (datetime('now')),
        vigencia_inicio        TEXT NOT NULL,
        vigencia_final         TEXT NOT NULL,
        prorroga_tolerancia    INTEGER NOT NULL DEFAULT 0,
        id_estado_qr           INTEGER NOT NULL DEFAULT 1,
        id_solicitud_visitante INTEGER NOT NULL,
        FOREIGN KEY (id_estado_qr)
          REFERENCES ca_estado_qr(id_estado_qr),
        FOREIGN KEY (id_solicitud_visitante)
          REFERENCES solicitud_visitante(id_solicitud_visitante)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS registro_acceso (
        id_registro              INTEGER PRIMARY KEY AUTOINCREMENT,
        hora_llegada_institucion TEXT,
        hora_llegada_encuentro   TEXT,
        hora_salida_encuentro    TEXT,
        hora_salida_institucion  TEXT,
        observaciones            TEXT,
        id_vigilante_entrada     INTEGER NOT NULL,
        id_vigilante_salida      INTEGER,
        id_qr                    INTEGER NOT NULL UNIQUE,
        FOREIGN KEY (id_qr) REFERENCES qr(id_qr)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS notificacion (
        id_notificacion INTEGER PRIMARY KEY AUTOINCREMENT,
        id_empleado     INTEGER NOT NULL,
        id_solicitud    INTEGER,
        tipo            TEXT NOT NULL,
        mensaje         TEXT,
        leida           INTEGER NOT NULL DEFAULT 0,
        fecha_creado    TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (id_solicitud) REFERENCES solicitud(id_solicitud)
          ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bitacora (
        id_bitacora INTEGER PRIMARY KEY AUTOINCREMENT,
        id_empleado INTEGER NOT NULL,
        accion      TEXT NOT NULL,
        modulo      TEXT,
        detalle     TEXT,
        ip_origen   TEXT,
        fecha_hora  TEXT DEFAULT (datetime('now'))
      )
    ''');
  }
}

// ==============================================================
// Archivo    : validators.dart
// Módulo     : core/utils
// Descripción: Validaciones reutilizables para formularios.
// ==============================================================

class Validators {
  Validators._();

  /// Correo institucional: debe tener @ y dominio.
  static String? correo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa tu correo institucional.';
    }
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(valor.trim())) {
      return 'El correo no tiene un formato válido.';
    }
    return null;
  }

  /// Contraseña: mínimo 6 caracteres.
  static String? contrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa tu contraseña.';
    }
    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  /// Teléfono: exactamente 10 dígitos numéricos.
  static String? telefono(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el número de teléfono (10 dígitos).';
    }
    final limpio = valor.trim().replaceAll(RegExp(r'\D'), '');
    if (limpio.length != 10) {
      return 'El teléfono debe tener exactamente 10 dígitos.';
    }
    return null;
  }

  /// Campo requerido genérico.
  static String? requerido(String? valor, String nombreCampo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El campo $nombreCampo es obligatorio.';
    }
    return null;
  }

  /// Correo personal (visitante): admite cualquier proveedor.
  static String? correoPersonal(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el correo del visitante.';
    }
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(valor.trim())) {
      return 'El correo no tiene un formato válido.';
    }
    return null;
  }

  /// Fecha de visita: debe ser hoy o posterior.
  static String? fechaFutura(DateTime? fecha) {
    if (fecha == null) return 'Selecciona la fecha de la visita.';
    final hoy = DateTime.now();
    final hoyNorm = DateTime(hoy.year, hoy.month, hoy.day);
    if (fecha.isBefore(hoyNorm)) {
      return 'La fecha debe ser hoy o en el futuro.';
    }
    return null;
  }
}
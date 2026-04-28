// =============================================================================
// Archivo    : escaner_qr_view.dart
// Módulo     : features/vigilante/presentation/views
// Descripción: Pantalla 2 — Escáner QR con cámara (mobile_scanner).
//              Valida el QR y navega al resultado automáticamente.
//              NOTA: mobile_scanner requiere permisos de cámara en android/ios.
// Autor      : Yadhira Anadanely Benitez Millan
// Versión    : 1.0.0
// Fecha      : 2026-04-27
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../bloc/vigilante_viewmodel.dart';
import 'resultado_escaneo_view.dart';

/// Pantalla de escaneo QR.
/// Usa mobile_scanner para acceso a la cámara. En modo demo
/// muestra un campo manual para ingresar el código.
class EscanerQrView extends StatefulWidget {
  const EscanerQrView({super.key});

  @override
  State<EscanerQrView> createState() => _EscanerQrViewState();
}

class _EscanerQrViewState extends State<EscanerQrView> {
  final _codigoCtrl = TextEditingController();
  bool  _escaneando = false;

  @override
  void dispose() {
    _codigoCtrl.dispose();
    super.dispose();
  }

  Future<void> _procesarCodigo(BuildContext context, String codigo) async {
    if (_escaneando || codigo.trim().isEmpty) return;
    setState(() => _escaneando = true);

    AppLogger.accionUsuario('QR procesado', contexto: {'codigo': codigo});

    await context.read<VigilanteViewModel>().procesarEscaneo(codigo.trim());

    if (!mounted) return;
    setState(() => _escaneando = false);

    // Navegar al resultado
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ResultadoEscaneoView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<VigilanteViewModel>();
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear QR',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ---------------------------------------------------------------
          // Área de cámara (placeholder — sustituir con MobileScanner)
          // ---------------------------------------------------------------
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fondo negro simulando cámara
                Container(color: Colors.black87),

                // Marco de escaneo
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.exitoVerde, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                // Línea de escaneo animada (visual)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.25,
                  child: Container(
                    width: 220,
                    height: 2,
                    color: AppColors.exitoVerde.withOpacity(.7),
                  ),
                ),

                // Instrucción
                Positioned(
                  bottom: 30,
                  child: Text(
                    'Apunta al código QR del visitante',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Nota modo demo
                const Positioned(
                  top: 20,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '📱 Modo demo: ingresa el código manualmente abajo',
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------------------------------------------------------------
          // Panel inferior: entrada manual (modo demo / fallback)
          // ---------------------------------------------------------------
          Container(
            color: AppColors.superficie0,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sm, AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                // Campo de código manual
                TextFormField(
                  controller: _codigoCtrl,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (v) => _procesarCodigo(context, v),
                  decoration: InputDecoration(
                    labelText: 'Código QR (ingreso manual)',
                    prefixIcon: const Icon(Icons.qr_code_rounded),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => _codigoCtrl.clear(),
                    ),
                    hintText: 'VIS-2026-001234',
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // Botón validar
                ElevatedButton.icon(
                  onPressed: _escaneando
                      ? null
                      : () => _procesarCodigo(context, _codigoCtrl.text),
                  icon: _escaneando
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.superficie0))
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(_escaneando ? 'Validando...' : 'Validar código'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.exitoVerde,
                    foregroundColor: AppColors.superficie0,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 8),

                // Demo rápido
                TextButton(
                  onPressed: () {
                    _codigoCtrl.text = 'VIS-2026-001234';
                  },
                  child: const Text('Usar código de demo',
                      style: TextStyle(color: AppColors.exitoVerde, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

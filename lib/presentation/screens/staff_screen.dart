import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/game_provider.dart';
import '../../core/utils/crypto_util.dart';

/// POSTO DE JESUS: recebe o mapa do Organizador e emite
/// o token TOTP do Perdão, que rotaciona a cada 15 segundos.
class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> with WidgetsBindingObserver {
  String _token = '';
  int _secondsLeft = CryptoUtil.periodSeconds;
  Timer? _timer;
  MobileScannerController? _scannerController;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshToken();
    // Sincroniza o token com o relógio global (janelas de 15s fechadas)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_scannerController == null) return;
    if (!state.index.isEven) {
      _scannerController?.stop();
    } else {
      _scannerController?.start();
    }
  }

  void _tick() {
    final now = DateTime.now();
    final left = CryptoUtil.periodSeconds - (now.second % CryptoUtil.periodSeconds);
    if (_secondsLeft == CryptoUtil.periodSeconds && left < _secondsLeft) {
      _refreshToken();
    }
    setState(() => _secondsLeft = left);
  }

  void _refreshToken() {
    setState(() {
      _token = CryptoUtil.generateStaffToken();
      _secondsLeft = CryptoUtil.periodSeconds;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _pasteProject(GameProvider game) async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (!mounted) return;
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      final ok = game.loadActiveProject(data.text!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? "Mapa recebido! Bênção concedida." : "Mapa inválido!"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nada copiado! Escaneie/copie o mapa do Organizador.")),
      );
    }
  }

  void _scanProject(BuildContext context, GameProvider game) {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _scanning = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Stack(
            alignment: Alignment.center,
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  if (!_scanning) return;
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final raw = barcodes.first.rawValue ?? "";
                    if (raw.isNotEmpty) {
                      _scanning = false;
                      final ok = game.loadActiveProject(raw);
                      _scannerController?.dispose();
                      _scannerController = null;
                      if (mounted) Navigator.pop(ctx);
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("QR não é um mapa válido!")),
                        );
                      }
                    }
                  }
                },
              ),
              IgnorePointer(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFB22222), width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Escaneie o mapa do Organizador",
                      style: TextStyle(color: Color(0xFFF0E6D2))),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    _scanning = false;
                    _scannerController?.dispose();
                    _scannerController = null;
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      _scanning = false;
      _scannerController?.dispose();
      _scannerController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("POSTO DE JESUS"),
        backgroundColor: const Color(0xFF5E0000),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (!game.isLoaded || game.activeProjectName == null)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey.shade600),
                      const SizedBox(height: 20),
                      Text(
                        "Aguardando Mapa...\nJesus precisa receber o mapa\ndo Organizador.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB22222),
                          minimumSize: const Size(240, 52),
                        ),
                        onPressed: () => _scanProject(context, game),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("Escanear Mapa do Organizador"),
                      ),
                      TextButton.icon(
                        onPressed: () => _pasteProject(game),
                        icon: const Icon(Icons.paste, size: 18),
                        label: const Text("ou colar projeto (teste)"),
                      ),
                    ],
                  ),
                )
              else ...[
                const SizedBox(height: 20),
                const Text("PROJETO ATIVO:", style: TextStyle(color: Colors.grey)),
                Text(game.activeProjectName!,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("${game.activeProject?.teamCount ?? 1} equipes abençoadas",
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFB22222).withAlpha(90), blurRadius: 30),
                        ],
                      ),
                      child: QrImageView(data: _token, size: 200, backgroundColor: Colors.white),
                    ),
                    // Anel de progresso da janela de 15 segundos
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        value: _secondsLeft / CryptoUtil.periodSeconds,
                        strokeWidth: 4,
                        color: const Color(0xFFB22222),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user, color: Color(0xFFB22222), size: 18),
                    SizedBox(width: 6),
                    Text("CÓDIGO DO PERDÃO",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(
                  _token,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text("renova em $_secondsLeft s",
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _token));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Perdão copiado: $_token")),
                    );
                  },
                  label: const Text("Copiar Token de Perdão"),
                ),
                TextButton(
                  onPressed: () => game.resetGame(),
                  child: const Text("Encerrar este Projeto", style: TextStyle(color: Colors.red)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

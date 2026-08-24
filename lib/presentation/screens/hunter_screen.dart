import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../providers/game_provider.dart';
import 'locked_view.dart';
import 'victory_view.dart';

class HunterScreen extends StatelessWidget {
  const HunterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    switch (game.status) {
      case GameStatus.idle:
        return _startView(context, game);
      case GameStatus.locked:
        return const LockedView();
      case GameStatus.finished:
        return const VictoryView();
      case GameStatus.playing:
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("PISTA ${game.progress + 1} de ${game.totalClues}"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF12100D), Color(0xFF241E17)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Contador de progresso com selos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(game.totalClues, (i) {
                  final done = i < game.progress;
                  final current = i == game.progress;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: current ? 22 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: done
                          ? const Color(0xFFD4AF37)
                          : (current ? const Color(0xFFFFD700) : Colors.white24),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: current
                          ? [BoxShadow(color: const Color(0xFFD4AF37).withAlpha(120), blurRadius: 8)]
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              const Icon(Icons.auto_stories, size: 60, color: Color(0xFFD4AF37)),
              const SizedBox(height: 24),
              Text(
                game.currentClue['v'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: Color(0xFFF0E6D2),
                ),
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB22222),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("ESCANEAR QR CODE FÍSICO", style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _openScanner(context, game),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _simulateScan(context, game),
                child: const Text("Simular Escaneamento (Digitar Código)",
                    style: TextStyle(color: Color(0xFF9C8B6E))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- INÍCIO: COLAR MAPA + ESCOLHER EQUIPE ----------

  Widget _startView(BuildContext context, GameProvider game) {
    return Scaffold(
      appBar: AppBar(title: const Text("INICIAR CAÇADA")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.explore, size: 90, color: Color(0xFFD4AF37)),
              const SizedBox(height: 24),
              const Text(
                "MATMON",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 8),
              ),
              const SizedBox(height: 8),
              const Text("Peça a bênção de Jesus para começar!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9C8B6E), fontSize: 16)),
              const SizedBox(height: 32),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF12100D),
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: const Icon(Icons.paste),
                label: const Text("Colar Mapa de Jesus", style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _pasteMapAndPickTeam(context, game),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pasteMapAndPickTeam(BuildContext context, GameProvider game) async {
    final messenger = ScaffoldMessenger.of(context);
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data?.text == null || data!.text!.trim().isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text("Nada copiado! Pegue o mapa com Jesus primeiro.")));
      return;
    }

    final mapJson = data.text!;
    int? teamCount = game.peekTeamCount(mapJson);
    if (teamCount == null || teamCount < 1) {
      messenger.showSnackBar(const SnackBar(
        content: Text("Mapa inválido! Verifique se copiou corretamente."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (!context.mounted) return;
    final team = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Escolha sua Equipe"),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: teamCount,
            itemBuilder: (ctx, i) {
              final n = i + 1;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _teamColors[i % _teamColors.length],
                  child: Text("$n", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                title: Text("Equipe $n"),
                onTap: () => Navigator.pop(ctx, n),
              );
            },
          ),
        ),
      ),
    );

    if (team != null) {
      game.startHunterGame(mapJson, team);
    }
  }

  static const List<Color> _teamColors = [
    Color(0xFFB22222), Color(0xFF1F6FEB), Color(0xFF2E7D32), Color(0xFFED6C02),
    Color(0xFF6A1B9A), Color(0xFF00838F), Color(0xFF795548), Color(0xFF37474F),
  ];

  // ---------- SELO PRETO: INTERDIÇÃO ----------

  // ---------- VITÓRIA: TESOURO ENCONTRADO ----------
  void _openScanner(BuildContext context, GameProvider game) {
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
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    game.validateQr(barcodes.first.rawValue ?? "");
                    Navigator.pop(ctx);
                  }
                },
              ),
              // Moldura de mira
              IgnorePointer(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD4AF37), width: 3),
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
                  child: const Text("Aponte para a cifra do local",
                      style: TextStyle(color: Color(0xFFF0E6D2))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateScan(BuildContext context, GameProvider game) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Simular QR Físico"),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Digite a cifra da palavra",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              game.validateQr(ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text("Validar"),
          ),
        ],
      ),
    );
  }
}

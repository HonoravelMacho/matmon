import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';

/// SELO PRETO: Tela de interdição total. O Caçador só sai dela
/// recebendo o token TOTP de Jesus (O Perdão / Selo Vermelho).
class LockedView extends StatefulWidget {
  const LockedView({super.key});

  @override
  State<LockedView> createState() => _LockedViewState();
}

class _LockedViewState extends State<LockedView> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _wrongToken = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _pastePardon(BuildContext context, GameProvider game) async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data?.text == null) return;

    game.applyPardon(data!.text!);
    if (game.status != GameStatus.playing && mounted) {
      setState(() => _wrongToken = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _wrongToken = false);
      });
    }
  }

  void _typePardon(BuildContext context, GameProvider game) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Código do Perdão"),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 8,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: "XXXXXXXX",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB22222)),
            onPressed: () {
              game.applyPardon(ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text("Aplicar Perdão", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: ScaleTransition(
        scale: CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
        child: Container(
          // Vinheta vermelha pulsante nas bordas
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.1,
              colors: [
                Colors.black,
                Colors.black.withAlpha(255),
                const Color(0xFF5E0000).withAlpha(_wrongToken ? 230 : 140),
              ],
              stops: const [0.45, 0.75, 1.0],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Selo preto com cadeado
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0D0D0D),
                        border: Border.all(color: const Color(0xFF8B0000), width: 4),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFB22222).withAlpha(90), blurRadius: 40),
                        ],
                      ),
                    ),
                    const Icon(Icons.lock, size: 80, color: Color(0xFF8B0000)),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  "SELO PRETO",
                  style: TextStyle(
                    color: Color(0xFFB22222),
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  child: Text(
                    "INTERDITO\nVocê errou a pista ou a ordem!\nNinguém avança sem o perdão de Jesus.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.6),
                  ),
                ),
                if (_wrongToken)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      "✝ Token inválido! Peça um novo código a Jesus.",
                      style: TextStyle(color: Color(0xFFB22222), fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB22222),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(260, 54),
                  ),
                  icon: const Icon(Icons.healing),
                  label: const Text("COLAR PERDÃO DE JESUS", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _pastePardon(context, game),
                ),
                TextButton(
                  onPressed: () => _typePardon(context, game),
                  child: const Text("Digitar código manualmente",
                      style: TextStyle(color: Color(0xFF9C8B6E))),
                ),
              ],
            ),
          ),
          ),
      ),
    );
  }
}

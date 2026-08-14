import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/game_provider.dart';

class HunterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    if (game.status == GameStatus.idle) return _startView(context, game);
    if (game.status == GameStatus.locked) return _lockedView(context, game);
    if (game.status == GameStatus.finished) return _finishedView(context, game);

    return Scaffold(
      appBar: AppBar(title: Text("PISTA ${game.progress + 1} de ${game.totalClues}")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 60, color: Colors.orange),
            SizedBox(height: 20),
            Text(game.currentClue['v']!, 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 22, fontStyle: FontStyle.italic)),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.qr_code_scanner),
              label: Text("ESCANEAR QR CODE FÍSICO"),
              onPressed: () => _openScanner(context, game),
            ),
            SizedBox(height: 10),
            // Botão para simular o escaneamento via teclado (Teste 1 celular)
            TextButton(
              onPressed: () => _simulateScan(context, game),
              child: Text("Simular Escaneamento (Digitar Código)"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _startView(BuildContext context, GameProvider game) {
    return Scaffold(
      appBar: AppBar(title: Text("INICIAR CAÇA")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Peça a bênção de Jesus para começar!"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                ClipboardData? data = await Clipboard.getData('text/plain');
                if (data?.text != null) {
                  // Por enquanto, forçamos a Equipe 1 no teste
                  game.startHunterGame(data!.text!, 1);
                }
              },
              child: Text("Colar Mapa de Jesus (Sincronizar)"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lockedView(BuildContext context, GameProvider game) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text("SELO PRETO", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
            Padding(
              padding: EdgeInsets.all(30),
              child: Text("Você errou a pista ou a ordem!\nProcure Jesus para receber o perdão.", 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                ClipboardData? data = await Clipboard.getData('text/plain');
                if (data?.text != null) game.applyPardon(data!.text!);
              },
              child: Text("Colar Perdão de Jesus"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _finishedView(BuildContext context, GameProvider game) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 100, color: Colors.amber),
            Text("TESOURO ENCONTRADO!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => game.reset(), child: Text("Voltar ao Início")),
          ],
        ),
      ),
    );
  }

  void _openScanner(BuildContext context, GameProvider game) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              game.validateQr(barcodes.first.rawValue ?? "");
              Navigator.pop(ctx);
            }
          },
        ),
      ),
    );
  }

  void _simulateScan(BuildContext context, GameProvider game) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Simular QR Físico"),
        content: TextField(controller: ctrl, decoration: InputDecoration(hintText: "Ex: 111 (Cifra de AGUA)")),
        actions: [
          ElevatedButton(onPressed: () {
            game.validateQr(ctrl.text);
            Navigator.pop(ctx);
          }, child: Text("Validar")),
        ],
      ),
    );
  }
}

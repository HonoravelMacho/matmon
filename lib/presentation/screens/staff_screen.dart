import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/game_provider.dart';
import '../../core/utils/crypto_util.dart';

class StaffScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    String pardonToken = CryptoUtil.generateStaffToken();

    return Scaffold(
      appBar: AppBar(
        title: Text("POSTO DE JESUS"),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (game.activeProjectName == null)
                Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        "Aguardando Mapa...\nJesus precisa escanear o QR do Organizador.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // Simulação de "Colar" para teste em 1 celular
                          ClipboardData? data = await Clipboard.getData('text/plain');
                          if (data?.text != null) {
                            game.loadActiveProject(data!.text!);
                          }
                        },
                        child: Text("Colar Projeto (Teste)"),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    SizedBox(height: 20),
                    Text("PROJETO ATIVO:", style: TextStyle(color: Colors.grey)),
                    Text(game.activeProjectName!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    QrImageView(data: pardonToken, size: 200, backgroundColor: Colors.white),
                    SizedBox(height: 10),
                    Text("CÓDIGO DO PERDÃO", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: pardonToken));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Token de Perdão copiado!")));
                      },
                      label: Text("Copiar Token de Perdão"),
                    ),
                    TextButton(
                      onPressed: () => game.resetGame(),
                      child: Text("Encerrar este Projeto", style: TextStyle(color: Colors.red)),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

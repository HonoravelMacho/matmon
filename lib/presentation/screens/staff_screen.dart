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
      appBar: AppBar(title: Text("POSTO DE JESUS"), backgroundColor: Colors.red[900], foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (game.projectName == null)
              Padding(
                padding: EdgeInsets.all(20),
                child: Text("Jesus precisa escanear o QR Code do Organizador para receber o mapa!"),
              )
            else
              Column(
                children: [
                  Text("PROJETO: ${game.projectName}"),
                  QrImageView(data: pardonToken, size: 200),
                  Text("CÓDIGO DE PERDÃO"),
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: pardonToken));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Token de Perdão copiado!")));
                    },
                    child: Text("Copiar Token de Perdão"),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/utils/crypto_util.dart';

class StaffScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String staffToken = CryptoUtil.generateStaffToken();
    return Scaffold(
      appBar: AppBar(title: Text("POSTO DE JESUS"), backgroundColor: Colors.red[900], foregroundColor: Colors.white),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("QR CODE DO PERDÃO", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            QrImageView(data: staffToken, size: 250, backgroundColor: Colors.white),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text("Este código muda a cada 15s.\nMostre ao Caçador para remover o Selo Preto.", textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

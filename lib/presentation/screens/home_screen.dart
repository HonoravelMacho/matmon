import 'package:flutter/material.dart';
import 'staff_screen.dart';
// Importaremos as outras telas conforme criarmos

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MATMON (מַטְמוֹן)"), centerTitle: true),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _card(context, "ORGANIZADOR", Icons.settings, Colors.blue, null),
          _card(context, "CAÇADOR", Icons.explore, Colors.orange, null),
          _card(context, "STAFF (JESUS)", Icons.verified_user, Colors.red, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => StaffScreen()));
          }),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, Color color, VoidCallback? onTap) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Toque para acessar"),
        onTap: onTap,
      ),
    );
  }
}

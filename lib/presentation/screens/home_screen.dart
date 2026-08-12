import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MATMON")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          MenuCard(title: "ORGANIZADOR", icon: Icons.settings, color: Colors.blue, onTap: () {}),
          MenuCard(title: "CAÇADOR", icon: Icons.explore, color: Colors.orange, onTap: () {}),
          MenuCard(title: "STAFF (JESUS)", icon: Icons.verified_user, color: Colors.red, onTap: () {}),
        ],
      ),
    );
  }
}
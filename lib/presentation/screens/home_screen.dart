import 'package:flutter/material.dart';
import 'staff_screen.dart';
import 'organizer_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MATMON"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _card(context, "ORGANIZADOR", Icons.settings, Colors.blue, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => OrganizerScreen()));
            }),
            _card(context, "CAÇADOR", Icons.explore, Colors.orange, null),
            _card(context, "STAFF (JESUS)", Icons.verified_user, Colors.red, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => StaffScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, Color color, VoidCallback? onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: onTap,
      ),
    );
  }
}

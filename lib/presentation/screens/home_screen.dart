import 'package:flutter/material.dart';
import 'staff_screen.dart';
import 'organizer_screen.dart';
import 'hunter_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MATMON (מַטְמוֹן)"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF12100D), Color(0xFF1E1812)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Icon(Icons.emoji_events, size: 72, color: Color(0xFFD4AF37)),
                const SizedBox(height: 12),
                const Text(
                  "CAÇA AO TESOURO BÍBLICO",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Color(0xFFF0E6D2),
                  ),
                ),
                Text(
                  "\"Onde estiver o teu tesouro...\" — Lucas 12:34",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 32),
                _card(context, "ORGANIZADOR", Icons.engineering, const Color(0xFF1F6FEB),
                    "Criar projetos e pistas", () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const OrganizerScreen()))),
                const SizedBox(height: 14),
                _card(context, "STAFF (JESUS)", Icons.verified_user, const Color(0xFFB22222),
                    "Bênção e Perdão das equipes", () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const StaffScreen()))),
                const SizedBox(height: 14),
                _card(context, "CAÇADOR", Icons.explore, const Color(0xFFED6C02),
                    "Seguir as pistas até o tesouro", () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const HunterScreen()))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, Color color,
      String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }
}

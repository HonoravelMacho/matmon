import os

# Conteúdos dos arquivos do Matmon
files = {
    "lib/core/constants/colors.dart": """import 'package:flutter/material.dart';
class MatmonColors {
  static const primaryGold = Color(0xFFD4AF37);
  static const deepBlack = Color(0xFF1A1A1A);
  static const bloodRed = Color(0xFF8B0000);
  static const parchment = Color(0xFFF5F5DC);
}""",

    "lib/core/utils/crypto_util.dart": """import 'dart:convert';
import 'package:crypto/crypto.dart';
class CryptoUtil {
  static String generateStaffToken() {
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 15000;
    var bytes = utf8.encode("MATMON_JESUS_$timestamp");
    return sha256.convert(bytes).toString().substring(0, 8).toUpperCase();
  }
}""",

    "lib/domain/entities/clue.dart": """class Clue {
  final String id;
  final String verseText;
  final String reference;
  final String keyword;
  Clue({required this.id, required this.verseText, required this.reference, required this.keyword});
}""",

    "lib/presentation/providers/game_provider.dart": """import 'package:flutter/material.dart';
import '../../domain/entities/clue.dart';
enum GameStatus { playing, locked, finished }
class GameProvider with ChangeNotifier {
  List<Clue> _route = [
    Clue(id: "1", verseText: "Lâmpada para os meus pés...", reference: "Salmos 119:105", keyword: "LUZ"),
    Clue(id: "2", verseText: "O Senhor é meu pastor...", reference: "Salmos 23:1", keyword: "NADA"),
  ];
  int _currentIndex = 0;
  GameStatus _status = GameStatus.playing;
  GameStatus get status => _status;
  Clue get currentClue => _route[_currentIndex];
  void validateQr(String scannedData) {
    if (scannedData == _route[_currentIndex].keyword) {
      _currentIndex++;
      if (_currentIndex >= _route.length) _status = GameStatus.finished;
    } else { _status = GameStatus.locked; }
    notifyListeners();
  }
  void unlock() { _status = GameStatus.playing; notifyListeners(); }
}""",

    "lib/presentation/widgets/menu_card.dart": """import 'package:flutter/material.dart';
class MenuCard extends StatelessWidget {
  final String title; final IconData icon; final Color color; final VoidCallback onTap;
  MenuCard({required this.title, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(leading: Icon(icon, color: color), title: Text(title), onTap: onTap));
  }
}""",

    "lib/presentation/screens/home_screen.dart": """import 'package:flutter/material.dart';
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
}""",

    "lib/main.dart": """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/game_provider.dart';
import 'presentation/screens/home_screen.dart';
void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => GameProvider(),
    child: MaterialApp(theme: ThemeData(useMaterial3: true), home: HomeScreen()),
  ));
}"""
}

for path, content in files.items():
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
print("✅ Código injetado com sucesso!")

import 'package:flutter/material.dart';
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
}
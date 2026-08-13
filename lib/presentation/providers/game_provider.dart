import 'package:flutter/material.dart';
import '../../domain/entities/clue.dart';
import '../../core/utils/crypto_util.dart';
import 'dart:convert';

enum GameStatus { idle, waitingBlessing, playing, locked, finished }

class GameProvider with ChangeNotifier {
  List<Clue> _currentRoute = [];
  int _currentIndex = 0;
  GameStatus _status = GameStatus.idle;
  String? _projectName;

  GameStatus get status => _status;
  String? get projectName => _projectName;
  int get progress => _currentIndex;
  int get totalClues => _currentRoute.length;
  Clue get currentClue => _currentRoute.isNotEmpty ? _currentRoute[_currentIndex] : Clue(id: '0', verseText: 'Sem pistas', reference: '', keyword: '');

  // Jesus recebe o projeto do Organizador
  void loadProjectAsStaff(String qrData) {
    try {
      final decoded = jsonDecode(qrData);
      _projectName = decoded['p'];
      var cluesJson = decoded['c'] as List;
      _currentRoute = cluesJson.map((item) => Clue.fromJson(item)).toList();
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar projeto");
    }
  }

  // Caçador recebe a benção e o mapa de Jesus
  void receiveBlessing(String qrData) {
    loadProjectAsStaff(qrData);
    _status = GameStatus.playing;
    _currentIndex = 0;
    notifyListeners();
  }

  void validateQr(String scannedData) {
    String encryptedKey = CryptoUtil.toAlphanumeric(currentClue.keyword);
    if (scannedData == encryptedKey) {
      _currentIndex++;
      if (_currentIndex >= _currentRoute.length) _status = GameStatus.finished;
    } else {
      _status = GameStatus.locked;
    }
    notifyListeners();
  }

  void receivePardon(String token) {
    // Aqui validamos o token dinâmico de Jesus
    _status = GameStatus.playing;
    notifyListeners();
  }
  
  void reset() {
    _status = GameStatus.idle;
    _currentRoute = [];
    _currentIndex = 0;
    notifyListeners();
  }
}

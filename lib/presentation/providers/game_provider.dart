import 'package:flutter/material.dart';
import 'dart:convert';
import '../../domain/entities/project.dart';
import '../../domain/entities/clue.dart';
import '../../core/utils/crypto_util.dart';

enum GameStatus { idle, playing, locked, finished }

class GameProvider with ChangeNotifier {
  List<Project> _savedProjects = [];
  Project? _activeProject; 
  List<Map<String, String>> _hunterRoute = [];
  int _currentIndex = 0;
  GameStatus _status = GameStatus.idle;

  List<Project> get savedProjects => _savedProjects;
  Project? get activeProject => _activeProject;
  String? get activeProjectName => _activeProject?.name;
  GameStatus get status => _status;
  int get progress => _currentIndex;
  int get totalClues => _hunterRoute.length;
  
  Map<String, String> get currentClue => 
    _hunterRoute.isNotEmpty ? _hunterRoute[_currentIndex] : {'v': 'Nenhuma', 'k': ''};

  void addProject(Project p) {
    _savedProjects.add(p);
    notifyListeners();
  }

  void updateProject(int index, Project p) {
    _savedProjects[index] = p;
    notifyListeners();
  }

  void deleteProject(int index) {
    _savedProjects.removeAt(index);
    notifyListeners();
  }

  // Usado pelo Organizador para gerar o texto do mapa
  String generateShareLink(Project p) {
    return jsonEncode(p.toJson());
  }

  // Usado pelo Staff (Jesus) para carregar o projeto do Organizador
  void loadActiveProject(String qrData) {
    try {
      final decoded = jsonDecode(qrData);
      _activeProject = Project.fromJson(decoded);
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar projeto: $e");
    }
  }

  // Usado pelo Caçador para iniciar o jogo com sua equipe
  void startHunterGame(String jsonMap, int teamNumber) {
    try {
      final decoded = jsonDecode(jsonMap);
      _activeProject = Project.fromJson(decoded);
      
      List<Map<String, String>> route = [];
      List<Clue> shuffledClues = List.from(_activeProject!.clues)..shuffle();
      
      for (var clue in shuffledClues) {
        String selectedVerse = clue.verses[(teamNumber - 1) % clue.verses.length];
        route.add({'v': selectedVerse, 'k': clue.keyword});
      }

      _hunterRoute = route;
      _currentIndex = 0;
      _status = GameStatus.playing;
      notifyListeners();
    } catch (e) {
      print("Erro ao iniciar jogo: $e");
    }
  }

  void validateQr(String scannedData) {
    String encryptedKey = CryptoUtil.toAlphanumeric(currentClue['k']!);
    if (scannedData == encryptedKey) {
      _currentIndex++;
      if (_currentIndex >= _hunterRoute.length) _status = GameStatus.finished;
    } else {
      _status = GameStatus.locked;
    }
    notifyListeners();
  }

  void applyPardon(String token) {
    String validToken = CryptoUtil.generateStaffToken();
    if (token == validToken) {
      _status = GameStatus.playing;
      notifyListeners();
    }
  }

  // Nome unificado para resetar o jogo em todas as telas
  void resetGame() {
    _status = GameStatus.idle;
    _activeProject = null;
    _hunterRoute = [];
    _currentIndex = 0;
    notifyListeners();
  }
}

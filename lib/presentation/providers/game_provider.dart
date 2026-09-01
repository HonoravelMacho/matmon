import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/clue.dart';
import '../../core/utils/crypto_util.dart';

enum GameStatus { idle, playing, locked, finished }

class GameProvider with ChangeNotifier {
  static const String _boxName = 'matmon_projects';
  static const String _boxKey = 'all_projects';

  List<Project> _savedProjects = [];
  Project? _activeProject;
  List<Map<String, String>> _hunterRoute = [];
  int _currentIndex = 0;
  GameStatus _status = GameStatus.idle;
  bool _loaded = false;

  List<Project> get savedProjects => List.unmodifiable(_savedProjects);
  Project? get activeProject => _activeProject;
  String? get activeProjectName => _activeProject?.name;
  GameStatus get status => _status;
  bool get isLoaded => _loaded;
  int get progress => _currentIndex;
  int get totalClues => _hunterRoute.length;

  Map<String, String> get currentClue =>
      _hunterRoute.isNotEmpty ? _hunterRoute[_currentIndex] : {'v': 'Nenhuma', 'k': ''};

  // ---------- PERSISTÊNCIA LOCAL (Hive) ----------

  Future<void> init() async {
    try {
      final box = await Hive.openBox(_boxName);
      final raw = box.get(_boxKey);
      if (raw != null && raw is List) {
        _savedProjects = raw.cast<Project>().toList();
      }
    } catch (_) {
      _savedProjects = [];
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_boxKey, _savedProjects);
    } catch (_) {
      // Falha silenciosa de disco não deve derrubar o jogo
    }
  }

  void addProject(Project p) {
    _savedProjects.add(p);
    notifyListeners();
    _persist();
  }

  void updateProject(int index, Project p) {
    if (index < 0 || index >= _savedProjects.length) return;
    _savedProjects[index] = p;
    notifyListeners();
    _persist();
  }

  void deleteProject(int index) {
    if (index < 0 || index >= _savedProjects.length) return;
    _savedProjects.removeAt(index);
    notifyListeners();
    _persist();
  }

  // ---------- SINCRONIZAÇÃO ORGANIZADOR -> JESUS -> CAÇADOR ----------

  // Usado pelo Organizador para gerar o texto do mapa (QR / copiar)
  String generateShareLink(Project p) {
    return jsonEncode(p.toJson());
  }

  // Decodifica um mapa sem iniciar o jogo (para saber quantas equipes existem)
  int? peekTeamCount(String mapJson) {
    try {
      final decoded = jsonDecode(mapJson);
      return decoded['tc'] as int?;
    } catch (_) {
      return null;
    }
  }

  // Usado pelo Staff (Jesus) para carregar o projeto do Organizador
  bool loadActiveProject(String mapJson) {
    try {
      final decoded = jsonDecode(mapJson);
      _activeProject = Project.fromJson(decoded);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Usado pelo Caçador para iniciar o jogo com sua equipe.
  // A rota é embaralhada de forma DETERMINÍSTICA (seed = nome do projeto + equipe),
  // garantindo que a mesma equipe sempre receba a mesma rota, em qualquer celular.
  bool startHunterGame(String mapJson, int teamNumber) {
    try {
      final decoded = jsonDecode(mapJson);
      _activeProject = Project.fromJson(decoded);

      final clues = _activeProject!.clues;
      if (clues.isEmpty) return false;

      // Embaralhamento determinístico por equipe
      final seed = (_activeProject!.name.hashCode * 31 + teamNumber * 7919) & 0x7FFFFFFF;
      final shuffledClues = List<Clue>.from(clues)..shuffle(Random(seed));

      // Distribuição anti-repetição: equipes vizinhas recebem versículos diferentes.
      // Ex.: 4 equipes e 2 versículos -> equipes 1,3 veem o 1º; equipes 2,4 veem o 2º.
      List<Map<String, String>> route = [];
      for (var clue in shuffledClues) {
        final teamVerses = clue.versesForTeam(teamNumber);
        if (teamVerses.isEmpty) continue;
        final selectedVerse = teamVerses[(teamNumber - 1) % teamVerses.length];
        route.add({'v': selectedVerse, 'k': clue.keyword});
      }

      _hunterRoute = route;
      _currentIndex = 0;
      _status = GameStatus.playing;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Validação do QR físico contra a cifra Gematria da palavra-chave
  void validateQr(String scannedData) {
    final expected = CryptoUtil.toAlphanumeric(currentClue['k'] ?? '');
    final received = scannedData.trim().toUpperCase();

    if (received == expected) {
      _currentIndex++;
      if (_currentIndex >= _hunterRoute.length) {
        _status = GameStatus.finished;
      }
    } else {
      // Selo Preto: bloqueio total por erro
      _status = GameStatus.locked;
    }
    notifyListeners();
  }

  // O Perdão (Selo Vermelho): destrava apenas com token TOTP válido do Staff
  void applyPardon(String token) {
    if (CryptoUtil.verifyPardonToken(token)) {
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

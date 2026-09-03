import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

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

  // Gera um link de compartilhamento "modo caçador" - apenas o necessário para a caça
  // Oculta o conteúdo bruto do mapa e pistas do organizador, permitindo apenas a jogabilidade
  String generateHunterShareLink(Project p) {
    // Cria uma versão simplificada: mantém a estrutura de clues com palavras-chave
    // mas em formato simplificado para o modo de caça
    final List<Map<String, dynamic>> simplifiedClues = [];
    for (var clue in p.clues) {
      final simplifiedCipher = CryptoUtil.toAlphanumeric(clue.keyword);
      simplifiedClues.add({
        'k': simplifiedCipher, // Apenas a cifra, não a palavra original
        'vbt': clue.versesByTeam.map((k, v) => MapEntry(k.toString(), v)),
      });
    }
    return jsonEncode({
      'n': p.name,
      'tc': p.teamCount,
      'c': simplifiedClues,
    });
  }

  // Decodifica um mapa no formato modo caçador
  Project? importHunterMapFromJson(String mapJson) {
    try {
      final decoded = jsonDecode(mapJson);
      // Transformar a cifra de volta - o Project.fromJson espera 'k' como palavra-chave
      // Mas temos apenas a cifra aqui, então precisamos tratar isso
      // Por enquanto, vamos tratar o 'k' como cifra alfanumérica direta
      final cluesList = decoded['c'] as List?;
      if (cluesList == null) return null;

      final List<Clue> clues = [];
      for (var clueJson in cluesList) {
        final cipher = clueJson['k'] ?? '';
        final vbt = clueJson['vbt'] as Map?;
        if (vbt != null) {
          final versesByTeam = (vbt as Map).map(
            (k, v) => MapEntry(int.parse(k.toString()), List<String>.from(v)),
          );
          clues.add(Clue(keyword: cipher, versesByTeam: versesByTeam));
        }
      }

      return Project(
        name: decoded['n'] ?? 'Projeto',
        teamCount: decoded['tc'] ?? p.teamCount,
        clues: clues,
      );
    } catch (_) {
      return null;
    }
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
        if (clue.verses.isEmpty) continue;
        final selectedVerse = clue.verses[(teamNumber - 1) % clue.verses.length];
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
    // Extrai apenas a cifra (parte antes de '|') se vier com formatação extra
    final received = scannedData.trim().toUpperCase().split('|').first;

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

  // ---------- EXPORTAR / IMPORTAR MAPAS PREMIAREADOS ----------

  // Exporta o mapa atual como texto JSON (todas as pistas separadas por palavra-chave)
  String exportMapAsJson(Project p) {
    return jsonEncode(p.toJson());
  }

  // Importa um mapa do texto JSON - retorna o objeto Project ou null se inválido
  Project? importMapFromJson(String mapJson) {
    try {
      final decoded = jsonDecode(mapJson);
      return Project.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  // Exporta o mapa para a área temporária do dispositivo e retorna o caminho do arquivo
  Future<String?> exportMapToFile(Project p) async {
    final json = exportMapAsJson(p);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/matmon_map_${p.name}.json');
    await file.writeAsString(json);
    return file.path;
  }
}

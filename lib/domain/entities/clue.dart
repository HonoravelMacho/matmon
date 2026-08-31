import 'dart:convert';
import 'dart:math';

class Clue {
  String id;
  String keyword;
  Map<int, List<String>> versesByTeam; // teamNumber -> verses

  Clue({String? id, required this.keyword, Map<int, List<String>>? versesByTeam})
      : id = id ?? (DateTime.now().microsecondsSinceEpoch * 1000 + Random().nextInt(1000)).toString(),
        versesByTeam = versesByTeam ?? {};

  // Construtor legado para compatibilidade
  Clue.legacy({String? id, required String keyword, required List<String> verses})
      : id = id ?? (DateTime.now().microsecondsSinceEpoch * 1000 + Random().nextInt(1000)).toString(),
        keyword = keyword,
        versesByTeam = {1: verses};

  Map<String, dynamic> toJson() => {
    'k': keyword,
    'vbt': versesByTeam.map((k, v) => MapEntry(k.toString(), v)),
  };

  factory Clue.fromJson(Map<String, dynamic> json) {
    final vbt = json['vbt'];
    if (vbt != null) {
      return Clue(
        keyword: json['k'] ?? '',
        versesByTeam: (vbt as Map).map(
          (k, v) => MapEntry(int.parse(k.toString()), List<String>.from(v)),
        ),
      );
    }
    // Compatibilidade com formato antigo
    return Clue.legacy(
      keyword: json['k'] ?? '',
      verses: List<String>.from(json['v'] ?? []),
    );
  }

  // Obter versículos para uma equipe específica
  List<String> versesForTeam(int teamNumber) {
    return versesByTeam[teamNumber] ?? versesByTeam[1] ?? [];
  }

  // Obter todos os números de equipe que têm versículos
  List<int> get teamNumbers => versesByTeam.keys.toList()..sort();

  // Verificar se a pista tem versículos para a equipe
  bool hasVersesForTeam(int teamNumber) {
    return versesForTeam(teamNumber).isNotEmpty;
  }
}

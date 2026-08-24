import 'dart:math';
import 'clue.dart';

class Project {
  String id;
  String name;
  int teamCount;
  List<Clue> clues;

  Project({String? id, required this.name, this.teamCount = 1, required this.clues})
      : id = id ?? (DateTime.now().microsecondsSinceEpoch * 1000 + Random().nextInt(1000)).toString();

  Map<String, dynamic> toJson() => {
    'n': name,
    'tc': teamCount,
    'c': clues.map((e) => e.toJson()).toList(),
  };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    name: json['n'] ?? 'Projeto',
    teamCount: json['tc'] ?? 1,
    clues: (json['c'] as List? ?? []).map((e) => Clue.fromJson(e)).toList(),
  );
}

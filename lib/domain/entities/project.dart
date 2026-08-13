import 'clue.dart';

class Project {
  String name;
  int teamCount;
  List<Clue> clues;
  Project({required this.name, this.teamCount = 1, required this.clues});

  Map<String, dynamic> toJson() => {
    'n': name,
    'tc': teamCount,
    'c': clues.map((e) => e.toJson()).toList(),
  };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    name: json['n'],
    teamCount: json['tc'],
    clues: (json['c'] as List).map((e) => Clue.fromJson(e)).toList(),
  );
}

import 'dart:math';

class Clue {
  String id;
  String keyword;
  List<String> verses; // Vários versículos para a mesma palavra

  Clue({String? id, required this.keyword, required this.verses})
      : id = id ?? (DateTime.now().microsecondsSinceEpoch * 1000 + Random().nextInt(1000)).toString();

  Map<String, dynamic> toJson() => {'k': keyword, 'v': verses};

  factory Clue.fromJson(Map<String, dynamic> json) => Clue(
    keyword: json['k'] ?? '',
    verses: List<String>.from(json['v'] ?? []),
  );
}

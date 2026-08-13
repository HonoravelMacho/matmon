class Clue {
  String id;
  String keyword;
  List<String> verses; // Vários versículos para a mesma palavra
  Clue({required this.id, required this.keyword, required this.verses});

  Map<String, dynamic> toJson() => {'k': keyword, 'v': verses};
  factory Clue.fromJson(Map<String, dynamic> json) => Clue(
    id: DateTime.now().hashCode.toString(),
    keyword: json['k'],
    verses: List<String>.from(json['v']),
  );
}

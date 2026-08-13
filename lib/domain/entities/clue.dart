class Clue {
  final String id;
  final String verseText;
  final String reference;
  final String keyword; // Palavra original (ex: AGUA)
  Clue({required this.id, required this.verseText, required this.reference, required this.keyword});

  // Converte para Map para virar QR Code
  Map<String, dynamic> toJson() => {
    'v': verseText,
    'r': reference,
    'k': keyword,
  };

  factory Clue.fromJson(Map<String, dynamic> json) => Clue(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    verseText: json['v'],
    reference: json['r'],
    keyword: json['k'],
  );
}

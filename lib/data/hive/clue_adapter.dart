import 'package:hive/hive.dart';
import '../../domain/entities/clue.dart';

// Adaptador manual da Clue para o Hive (sem codegen)
class ClueAdapter extends TypeAdapter<Clue> {
  @override
  final int typeId = 32;

  @override
  Clue read(BinaryReader reader) {
    final id = reader.readString();
    final keyword = reader.readString();
    final teamCount = reader.readInt();
    final versesByTeam = <int, List<String>> {};
    for (int i = 0; i < teamCount; i++) {
      final verseListLength = reader.readInt();
      final verses = List<String>.generate(verseListLength, (_) => reader.readString());
      versesByTeam[i + 1] = verses;
    }
    return Clue(keyword: keyword, versesByTeam: versesByTeam);
  }

  @override
  void write(BinaryWriter writer, Clue obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.keyword);
    final teamCount = obj.versesByTeam.length;
    writer.writeInt(teamCount);
    if (teamCount > 0) {
      final teamNumbers = obj.versesByTeam.keys.toList()..sort();
      for (final teamNum in teamNumbers) {
        final verses = obj.versesByTeam[teamNum];
        if (verses != null) {
          writer.writeInt(verses.length);
          for (final verse in verses) {
            writer.writeString(verse);
          }
        }
      }
    }
  }
}

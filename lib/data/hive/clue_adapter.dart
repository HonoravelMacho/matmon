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
    final versesByTeam = <int, List<String>>{};
    for (int i = 0; i < teamCount; i++) {
      final teamNumber = reader.readInt();
      final verseCount = reader.readInt();
      final verses = List.generate(verseCount, (_) => reader.readString());
      versesByTeam[teamNumber] = verses;
    }
    return Clue(id: id, keyword: keyword, versesByTeam: versesByTeam);
  }

  @override
  void write(BinaryWriter writer, Clue obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.keyword);
    writer.writeInt(obj.versesByTeam.length);
    obj.versesByTeam.forEach((teamNumber, verses) {
      writer.writeInt(teamNumber);
      writer.writeInt(verses.length);
      for (final verse in verses) {
        writer.writeString(verse);
      }
    });
  }
}

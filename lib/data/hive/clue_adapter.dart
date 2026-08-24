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
    final verseCount = reader.readInt();
    final verses = List.generate(verseCount, (_) => reader.readString());
    return Clue(id: id, keyword: keyword, verses: verses);
  }

  @override
  void write(BinaryWriter writer, Clue obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.keyword);
    writer.writeInt(obj.verses.length);
    for (final verse in obj.verses) {
      writer.writeString(verse);
    }
  }
}

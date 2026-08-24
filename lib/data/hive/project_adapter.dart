import 'package:hive/hive.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/clue.dart';

// Adaptador manual do Project para o Hive (sem codegen)
class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 31;

  @override
  Project read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final teamCount = reader.readInt();
    final clueCount = reader.readInt();
    final clues = List.generate(clueCount, (_) => reader.read() as Clue);
    return Project(id: id, name: name, teamCount: teamCount, clues: clues);
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.teamCount);
    writer.writeInt(obj.clues.length);
    for (final clue in obj.clues) {
      writer.write(clue);
    }
  }
}

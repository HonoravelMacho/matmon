import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/clue.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectIndex;
  ProjectDetailScreen({required this.projectIndex});

  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final project = provider.savedProjects[widget.projectIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              String link = provider.generateShareLink(project);
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Mapa copiado! Cole na tela de Jesus.")),
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: project.clues.length,
        itemBuilder: (ctx, i) => Card(
          child: ListTile(
            title: Text("Palavra: ${project.clues[i].keyword}"),
            subtitle: Text("${project.clues[i].verses.length} Versículos cadastrados"),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() => project.clues.removeAt(i));
                provider.updateProject(widget.projectIndex, project);
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Nova Pista"),
        icon: Icon(Icons.add),
        onPressed: () => _showAddClueDialog(context, provider, project),
      ),
    );
  }

  void _showAddClueDialog(BuildContext context, GameProvider provider, Project project) {
    final keyCtrl = TextEditingController();
    final verseCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Adicionar Pista"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: keyCtrl, decoration: InputDecoration(labelText: "Palavra-Chave (Ex: AGUA)")),
            TextField(controller: verseCtrl, decoration: InputDecoration(labelText: "Versículo Bíblico"), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                project.clues.add(Clue(
                  id: DateTime.now().toString(),
                  keyword: keyCtrl.text.toUpperCase(),
                  verses: [verseCtrl.text],
                ));
              });
              provider.updateProject(widget.projectIndex, project);
              Navigator.pop(ctx);
            },
            child: Text("Salvar"),
          ),
        ],
      ),
    );
  }
}

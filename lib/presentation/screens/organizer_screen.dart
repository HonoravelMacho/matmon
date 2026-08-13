import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../../domain/entities/project.dart';
import 'project_detail_screen.dart';

class OrganizerScreen extends StatefulWidget {
  @override
  _OrganizerScreenState createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen> {
  final nameCtrl = TextEditingController();
  final teamCtrl = TextEditingController(text: "1");

  @override
  Widget build(BuildContext context) {
    final projects = Provider.of<GameProvider>(context).savedProjects;
    return Scaffold(
      appBar: AppBar(title: Text("MEUS PROJETOS")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProject(context),
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (ctx, i) => Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(projects[i].name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${projects[i].teamCount} Equipes | ${projects[i].clues.length} Pistas"),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => Provider.of<GameProvider>(context, listen: false).deleteProject(i),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(projectIndex: i),
              ));
            },
          ),
        ),
      ),
    );
  }

  void _showAddProject(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Novo Projeto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Nome do Evento")),
            TextField(controller: teamCtrl, decoration: InputDecoration(labelText: "Nº de Equipes"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final p = Project(name: nameCtrl.text, teamCount: int.parse(teamCtrl.text), clues: []);
              Provider.of<GameProvider>(context, listen: false).addProject(p);
              Navigator.pop(ctx);
              nameCtrl.clear();
            },
            child: Text("Criar"),
          ),
        ],
      ),
    );
  }
}

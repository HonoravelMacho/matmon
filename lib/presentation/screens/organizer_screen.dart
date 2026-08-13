import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/clue.dart';

class OrganizerScreen extends StatefulWidget {
  @override
  _OrganizerScreenState createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen> {
  final nameCtrl = TextEditingController();
  final teamCtrl = TextEditingController(text: "1");

  void _showAddProject() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Novo Projeto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Nome")),
            TextField(controller: teamCtrl, decoration: InputDecoration(labelText: "Nº de Equipes"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancelar")),
          ElevatedButton(onPressed: () {
            final p = Project(name: nameCtrl.text, teamCount: int.parse(teamCtrl.text), clues: []);
            Provider.of<GameProvider>(context, listen: false).addProject(p);
            Navigator.pop(ctx);
          }, child: Text("Criar")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = Provider.of<GameProvider>(context).savedProjects;
    return Scaffold(
      appBar: AppBar(title: Text("MEUS PROJETOS")),
      floatingActionButton: FloatingActionButton(onPressed: _showAddProject, child: Icon(Icons.add)),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (ctx, i) => Card(
          margin: EdgeInsets.all(8),
          child: ListTile(
            title: Text(projects[i].name),
            subtitle: Text("${projects[i].teamCount} Equipes | ${projects[i].clues.length} Pistas"),
            trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => Provider.of<GameProvider>(context, listen: false).deleteProject(i)),
            onTap: () {
              // Aqui abriremos a edição de pistas no próximo passo
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Em breve: Editar pistas de ${projects[i].name}")));
            },
          ),
        ),
      ),
    );
  }
}

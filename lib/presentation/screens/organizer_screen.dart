import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../../domain/entities/project.dart';
import 'project_detail_screen.dart';

class OrganizerScreen extends StatefulWidget {
  const OrganizerScreen({super.key});

  @override
  State<OrganizerScreen> createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen> {
  @override
  Widget build(BuildContext context) {
    final projects = Provider.of<GameProvider>(context).savedProjects;

    return Scaffold(
      appBar: AppBar(title: const Text("MEUS PROJETOS")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProject(context),
        child: const Icon(Icons.add),
      ),
      body: projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 70, color: Colors.grey.shade600),
                  const SizedBox(height: 12),
                  const Text(
                    "Nenhum projeto salvo.\nCrie seu primeiro evento!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: projects.length,
              itemBuilder: (ctx, i) {
                final p = projects[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(40),
                      child: Icon(Icons.inventory_2,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${p.teamCount} Equipes | ${p.clues.length} Pistas"),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _showEditProject(context, i, p);
                            break;
                          case 'delete':
                            _confirmDelete(context, i, p.name);
                            break;
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Editar Projeto'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.redAccent),
                            title: Text('Excluir', style: TextStyle(color: Colors.redAccent)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProjectDetailScreen(projectIndex: i)),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddProject(BuildContext context) {
    final nameCtrl = TextEditingController();
    final teamCtrl = TextEditingController(text: "2");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Novo Projeto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration:
                  const InputDecoration(labelText: "Nome do Evento (Ex: Acampamento 2026)"),
            ),
            TextField(
              controller: teamCtrl,
              decoration:
                  const InputDecoration(labelText: "Nº de Equipes", hintText: "Ex: 4"),
              keyboardType: TextInputType.number,
              maxLength: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final teams = int.tryParse(teamCtrl.text) ?? 0;
              if (name.isEmpty || teams < 1 || teams > 20) return;

              Provider.of<GameProvider>(context, listen: false)
                  .addProject(Project(name: name, teamCount: teams, clues: []));
              Navigator.pop(ctx);
            },
            child: const Text("Criar"),
          ),
        ],
      ),
    );
  }

  void _showEditProject(BuildContext context, int index, Project project) {
    final nameCtrl = TextEditingController(text: project.name);
    final teamCtrl = TextEditingController(text: project.teamCount.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Editar Projeto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration:
                  const InputDecoration(labelText: "Nome do Evento"),
            ),
            TextField(
              controller: teamCtrl,
              decoration:
                  const InputDecoration(labelText: "Nº de Equipes", hintText: "Ex: 4"),
              keyboardType: TextInputType.number,
              maxLength: 2,
            ),
            if (project.clues.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "Atenção: Alterar o nº de equipes pode afetar pistas existentes.",
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final teams = int.tryParse(teamCtrl.text) ?? 0;
              if (name.isEmpty || teams < 1 || teams > 20) return;

              final updatedProject = Project(
                id: project.id,
                name: name,
                teamCount: teams,
                clues: project.clues,
              );
              Provider.of<GameProvider>(context, listen: false)
                  .updateProject(index, updatedProject);
              Navigator.pop(ctx);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int index, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Excluir \"$name\"?"),
        content: const Text(
            "Esta ação é permanente e apaga todas as pistas salvas."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Provider.of<GameProvider>(context, listen: false).deleteProject(index);
    }
  }
}

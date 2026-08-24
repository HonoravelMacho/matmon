import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/game_provider.dart';
import '../../core/utils/crypto_util.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/clue.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectIndex;
  const ProjectDetailScreen({super.key, required this.projectIndex});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    if (widget.projectIndex >= provider.savedProjects.length) {
      // Projeto removido enquanto esta tela estava aberta
      Navigator.of(context).maybePop();
    }
    final project = provider.savedProjects[widget.projectIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            tooltip: "Mostrar QR para o Staff",
            icon: const Icon(Icons.qr_code_2),
            onPressed: () => _showMapQr(context, provider, project),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              String link = provider.generateShareLink(project);
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Mapa copiado! Cole na tela de Jesus.")),
              );
            },
          ),
        ],
      ),
      body: project.clues.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 70, color: Colors.grey.shade600),
                  const SizedBox(height: 12),
                  const Text("Nenhuma pista ainda.\nToque em 'Nova Pista' para começar.",
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: project.clues.length,
              itemBuilder: (ctx, i) {
                final clue = project.clues[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(40),
                      child: Text("${i + 1}",
                          style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ),
                    title: Text(clue.keyword,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Cifra física: ${CryptoUtil.toAlphanumeric(clue.keyword)}"),
                        Text("${clue.verses.length} versículo(s) cadastrado(s)"),
                      ],
                    ),
                    children: [
                      ...clue.verses.asMap().entries.map((e) => ListTile(
                            dense: true,
                            leading: Icon(Icons.menu_book, size: 18, color: Colors.grey.shade600),
                            title: Text(e.value, style: const TextStyle(fontSize: 14)),
                          )),
                      ListTile(
                        dense: true,
                        textColor: Colors.redAccent,
                        iconColor: Colors.redAccent,
                        onTap: () {
                          setState(() => project.clues.removeAt(i));
                          provider.updateProject(widget.projectIndex, project);
                        },
                        leading: const Icon(Icons.delete_outline),
                        title: const Text("Excluir pista"),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Nova Pista"),
        icon: const Icon(Icons.add),
        onPressed: () => _showAddClueDialog(context, provider, project),
      ),
    );
  }

  void _showMapQr(BuildContext context, GameProvider provider, Project project) {
    String mapJson = provider.generateShareLink(project);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("MAPA DO TESOURO",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              const Text("Peça para o Staff (Jesus) escanear este código",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(data: mapJson, size: 260, backgroundColor: Colors.white),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text("Ou copiar como texto"),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: mapJson));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mapa copiado como texto!")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddClueDialog(BuildContext context, GameProvider provider, Project project) {
    final keyCtrl = TextEditingController();
    final verses = <TextEditingController>[TextEditingController()];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Nova Pista"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: keyCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: "Palavra-Chave (Ex: AGUA)",
                    helperText: keyCtrl.text.isEmpty
                        ? null
                        : "Cifra: ${CryptoUtil.toAlphanumeric(keyCtrl.text)}",
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 16),
                const Text("Versículos desta pista:",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ...verses.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: e.value,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: "Versículo ${e.key + 1} (uma equipe por versículo)",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          if (verses.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                              onPressed: () =>
                                  setDialogState(() => verses.removeAt(e.key)),
                            ),
                        ],
                      ),
                    )),
                TextButton.icon(
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text("Adicionar outro versículo"),
                  onPressed: () =>
                      setDialogState(() => verses.add(TextEditingController())),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                final keyword = keyCtrl.text.trim().toUpperCase();
                final verseList = verses
                    .map((c) => c.text.trim())
                    .where((t) => t.isNotEmpty)
                    .toList();
                if (keyword.isEmpty || verseList.isEmpty) return;

                setState(() {
                  project.clues.add(Clue(keyword: keyword, verses: verseList));
                });
                provider.updateProject(widget.projectIndex, project);
                Navigator.pop(ctx);
              },
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}

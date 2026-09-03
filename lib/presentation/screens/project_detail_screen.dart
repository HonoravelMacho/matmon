import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:gal/gal.dart';

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
              // Pergunta ao usuário qual tipo de compartilhamento deseja
              _showShareOptions(context, provider, project);
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
                        Text("${clue.teamNumbers.length} equipe(s) com versículos"),
                      ],
                    ),
                    children: [
                      ...clue.teamNumbers.map((teamNum) {
                        final verses = clue.versesForTeam(teamNum);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                "Equipe $teamNum (${verses.length} versículo(s))",
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFFD4AF37)),
                              ),
                            ),
                            ...verses.asMap().entries.map((e) => ListTile(
                                  dense: true,
                                  leading: Icon(Icons.menu_book, size: 18, color: Colors.grey.shade600),
                                  title: Text(e.value, style: const TextStyle(fontSize: 14)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.qr_code, size: 20, color: Color(0xFFD4AF37)),
                                    tooltip: "Ver/baixar QR desta pista",
                                    onPressed: () => _showClueQr(context, clue, teamNum, e.key),
                                  ),
                                )),
                          ],
                        );
                      }),
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

  void _showShareOptions(BuildContext context, GameProvider provider, Project project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Compartilhar Mapa"),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text("Compartilhar Completo (Organizador)"),
                subtitle: const Text("Compartilha todas as pistas e versículos"),
                onTap: () {
                  Navigator.pop(ctx);
                  String link = provider.generateShareLink(project);
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mapa completo copiado! Cole na tela de Jesus.")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.sports_esports),
                title: const Text("Compartilhar Modo Caça"),
                subtitle: const Text("Apenas o necessário para caçar pistas"),
                onTap: () {
                  Navigator.pop(ctx);
                  String link = provider.generateHunterShareLink(project);
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mapa modo caça copiado! Cole na tela de Jesus ou caçadores.")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text("Exportar Mapa"),
                subtitle: const Text("Salva o mapa no dispositivo"),
                onTap: () async {
                  Navigator.pop(ctx);
                  final filePath = await provider.exportMapToFile(project);
                  if (filePath != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Mapa exportado: ${filePath.split('/').last}")),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.import_contacts),
                title: const Text("Importar Mapa"),
                subtitle: const Text("Carrega um mapa exportado anteriormente"),
                onTap: () async {
                  Navigator.pop(ctx);
                  // TODO: Implementar seletor de arquivo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Funcionalidade em desenvolvimento")),
                  );
                },
              ),
            ],
          ),
        ),
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

  void _showClueQr(BuildContext context, Clue clue, int teamNum, int verseIndex) {
    final verse = clue.versesForTeam(teamNum)[verseIndex];
    final cipher = CryptoUtil.toAlphanumeric(clue.keyword);
    final qrData = "$cipher|$teamNum|$verseIndex";

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("PISTA: ${clue.keyword}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Equipe $teamNum • Versículo ${verseIndex + 1}",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text("Cifra: $cipher",
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(data: qrData, size: 260, backgroundColor: Colors.white),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text("Copiar Cifra"),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: cipher));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Cifra copiada!")),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text("Baixar QR"),
                      onPressed: () => _downloadQrImage(context, qrData, clue.keyword, teamNum, verseIndex),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text("Compartilhar QR"),
                onPressed: () => _shareQrImage(qrData, clue.keyword, teamNum, verseIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadQrImage(BuildContext context, String data, String keyword, int teamNum, int verseIndex) async {
    try {
      final qrPainter = QrPainter(data: data, version: QrVersions.auto, gapless: true);
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final size = 500.0;
      qrPainter.paint(canvas, Size(size, size));
      final picture = pictureRecorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final file = File('${directory.path}/matmon_${keyword}_eq${teamNum}_v${verseIndex + 1}.png');
          await file.writeAsBytes(byteData.buffer.asUint8List());
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("QR salvo em: ${file.path}")),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar QR: $e")),
        );
      }
    }
  }

  Future<void> _shareQrImage(String data, String keyword, int teamNum, int verseIndex) async {
    try {
      final qrPainter = QrPainter(data: data, version: QrVersions.auto, gapless: true);
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final size = 500.0;
      qrPainter.paint(canvas, Size(size, size));
      final picture = pictureRecorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/matmon_${keyword}_eq${teamNum}_v${verseIndex + 1}.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        await Share.shareXFiles([XFile(file.path)], text: "QR Code da pista: $keyword (Equipe $teamNum)");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao compartilhar QR: $e")),
        );
      }
    }
  }

  void _showAddClueDialog(BuildContext context, GameProvider provider, Project project) {
    final keyCtrl = TextEditingController();
    final versesByTeam = <int, List<TextEditingController>>{};

    // Inicializar com 1 controlador por equipe
    for (int t = 1; t <= project.teamCount; t++) {
      versesByTeam[t] = [TextEditingController()];
    }

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
                const Text("Versículos por equipe:",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ...project.teamCount > 1
                    ? List.generate(project.teamCount, (teamIdx) {
                        final teamNum = teamIdx + 1;
                        final controllers = versesByTeam[teamNum]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Text("Equipe $teamNum:", style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFD4AF37))),
                            ...controllers.asMap().entries.map((e) => Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: e.value,
                                          maxLines: 2,
                                          decoration: InputDecoration(
                                            labelText: "Versículo ${e.key + 1}",
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      if (controllers.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                          onPressed: () =>
                                              setDialogState(() => controllers.removeAt(e.key)),
                                        ),
                                    ],
                                  ),
                                )),
                            TextButton.icon(
                              icon: const Icon(Icons.add_circle_outline, size: 18),
                              label: const Text("Adicionar versículo"),
                              onPressed: () =>
                                  setDialogState(() => controllers.add(TextEditingController())),
                            ),
                          ],
                        );
                      })
                    : [
                        ...versesByTeam[1]!.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: e.value,
                                      maxLines: 2,
                                      decoration: InputDecoration(
                                        labelText: "Versículo ${e.key + 1}",
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  if (versesByTeam[1]!.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                      onPressed: () =>
                                          setDialogState(() => versesByTeam[1]!.removeAt(e.key)),
                                    ),
                                ],
                              ),
                            )),
                        TextButton.icon(
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text("Adicionar versículo"),
                          onPressed: () =>
                              setDialogState(() => versesByTeam[1]!.add(TextEditingController())),
                        ),
                      ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                final keyword = keyCtrl.text.trim().toUpperCase();
                final versesByTeamFinal = <int, List<String>>{};
                
                for (int t = 1; t <= project.teamCount; t++) {
                  final verseList = versesByTeam[t]!
                      .map((c) => c.text.trim())
                      .where((t) => t.isNotEmpty)
                      .toList();
                  if (verseList.isNotEmpty) {
                    versesByTeamFinal[t] = verseList;
                  }
                }
                
                if (keyword.isEmpty || versesByTeamFinal.isEmpty) return;

                setState(() {
                  project.clues.add(Clue(keyword: keyword, versesByTeam: versesByTeamFinal));
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

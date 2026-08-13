import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../domain/entities/clue.dart';

class OrganizerScreen extends StatefulWidget {
  @override
  _OrganizerScreenState createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen> {
  List<Clue> myClues = [];
  final nameCtrl = TextEditingController(text: "Missão Betel");

  void addClue() {
    setState(() {
      myClues.add(Clue(id: "1", verseText: "Texto do Versículo", reference: "Ref 1:1", keyword: "ALVO"));
    });
  }

  @override
  Widget build(BuildContext context) {
    String projectJson = jsonEncode({
      'p': nameCtrl.text,
      'c': myClues.map((e) => e.toJson()).toList(),
    });

    return Scaffold(
      appBar: AppBar(title: Text("CRIAR CAÇA AO TESOURO")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Nome do Projeto")),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: myClues.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(myClues[index].keyword),
                subtitle: Text(myClues[index].reference),
                trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => setState(() => myClues.removeAt(index))),
              ),
            ),
          ),
          if (myClues.isNotEmpty)
            QrImageView(data: projectJson, size: 150),
          ElevatedButton(onPressed: addClue, child: Text("Adicionar Pista (Exemplo)"))
        ],
      ),
    );
  }
}

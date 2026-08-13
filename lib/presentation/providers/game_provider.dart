import 'package:flutter/material.dart';
import 'dart:convert';
import '../../domain/entities/project.dart';
import '../../domain/entities/clue.dart';

class GameProvider with ChangeNotifier {
  List<Project> _savedProjects = [];
  Project? _activeProject; // O projeto que está sendo jogado agora

  List<Project> get savedProjects => _savedProjects;
  Project? get activeProject => _activeProject;
  String? get activeProjectName => _activeProject?.name;

  void addProject(Project p) {
    _savedProjects.add(p);
    notifyListeners();
  }

  void deleteProject(int index) {
    _savedProjects.removeAt(index);
    notifyListeners();
  }

  // Jesus ou Caçador carregam o mapa recebido
  void loadActiveProject(String qrData) {
    try {
      final decoded = jsonDecode(qrData);
      _activeProject = Project.fromJson(decoded);
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar projeto: $e");
    }
  }

  void resetGame() {
    _activeProject = null;
    notifyListeners();
  }
}

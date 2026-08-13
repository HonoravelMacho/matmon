import 'package:flutter/material.dart';
import 'dart:convert';
import '../../domain/entities/project.dart';
import '../../domain/entities/clue.dart';

class GameProvider with ChangeNotifier {
  List<Project> _savedProjects = [];
  Project? _activeProject; 

  List<Project> get savedProjects => _savedProjects;
  Project? get activeProject => _activeProject;
  String? get activeProjectName => _activeProject?.name;

  void addProject(Project p) {
    _savedProjects.add(p);
    notifyListeners();
  }

  void updateProject(int index, Project p) {
    _savedProjects[index] = p;
    notifyListeners();
  }

  void deleteProject(int index) {
    _savedProjects.removeAt(index);
    notifyListeners();
  }

  // Gera o "Link PIX" (JSON) do projeto para enviar para Jesus
  String generateShareLink(Project p) {
    return jsonEncode(p.toJson());
  }

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

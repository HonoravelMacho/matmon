import 'package:flutter/material.dart';
import 'dart:convert';
import '../../domain/entities/project.dart';
import '../../domain/entities/clue.dart';

class GameProvider with ChangeNotifier {
  List<Project> _savedProjects = [];
  List<Project> get savedProjects => _savedProjects;

  // Lógica de Embaralhamento para as Equipes
  List<Map<String, dynamic>> generateTeamRoutes(Project project) {
    List<Map<String, dynamic>> teamRoutes = [];
    
    for (int t = 0; t < project.teamCount; t++) {
      List<Clue> shuffledClues = List.from(project.clues)..shuffle();
      List<Map<String, String>> route = [];

      for (var clue in shuffledClues) {
        // Se tem menos versículos que equipes, ele repete aleatoriamente
        String selectedVerse = clue.verses[t % clue.verses.length];
        route.add({
          'v': selectedVerse,
          'k': clue.keyword,
        });
      }
      teamRoutes.add({'team': t + 1, 'route': route});
    }
    return teamRoutes;
  }

  void addProject(Project p) {
    _savedProjects.add(p);
    notifyListeners();
  }

  void deleteProject(int index) {
    _savedProjects.removeAt(index);
    notifyListeners();
  }
}

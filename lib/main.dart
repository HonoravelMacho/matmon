import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/game_provider.dart';
import 'presentation/screens/home_screen.dart';
void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => GameProvider(),
    child: MaterialApp(theme: ThemeData(useMaterial3: true), home: HomeScreen()),
  ));
}
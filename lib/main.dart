import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'data/hive/clue_adapter.dart';
import 'data/hive/project_adapter.dart';
import 'presentation/providers/game_provider.dart';
import 'presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Hive para persistência local dos projetos
  await Hive.initFlutter();
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(ClueAdapter());

  final gameProvider = GameProvider();
  await gameProvider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: gameProvider,
      child: const MatmonApp(),
    ),
  );
}

class MatmonApp extends StatelessWidget {
  const MatmonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MATMON (מַטְמוֹן)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B6914),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFFD4AF37), // Ouro
          secondary: const Color(0xFFB22222), // Vermelho selo
          surface: const Color(0xFF1A1410),
        ),
        scaffoldBackgroundColor: const Color(0xFF12100D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1410),
          foregroundColor: Color(0xFFD4AF37),
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF241E17),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

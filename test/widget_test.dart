import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:matmon/presentation/providers/game_provider.dart';
import 'package:matmon/presentation/screens/home_screen.dart';

void main() {
  testWidgets('App inicia e mostra a HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameProvider(),
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const HomeScreen(),
        ),
      ),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}

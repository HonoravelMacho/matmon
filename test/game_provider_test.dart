import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matmon/core/utils/crypto_util.dart';
import 'package:matmon/domain/entities/clue.dart';
import 'package:matmon/domain/entities/project.dart';
import 'package:matmon/presentation/providers/game_provider.dart';

void main() {
  // Garante que os bindings existam para o provider (usa Hive apenas em persistência)
  TestWidgetsFlutterBinding.ensureInitialized();

  Project buildProject() {
    return Project(
      name: 'Acampamento Teste',
      teamCount: 4,
      clues: [
        Clue(keyword: 'PAO', verses: ['João 6:35', 'Êxodo 16:4']),
        Clue(keyword: 'AGUA', verses: ['João 4:14', 'Números 20:11']),
        Clue(keyword: 'LUZ', verses: ['João 8:12']),
      ],
    );
  }

  group('GameProvider - rotas por equipe', () {
    test('Distribui versículos sem repetição entre equipes vizinhas', () {
      final game = GameProvider();
      final mapJson = jsonEncode(buildProject().toJson());

      Map<String, String> coletarRota() {
        final rota = <String, String>{};
        for (int i = 0; i < game.totalClues; i++) {
          rota[game.currentClue['k']!] = game.currentClue['v']!;
          game.validateQr(CryptoUtil.toAlphanumeric(game.currentClue['k']!));
        }
        return rota;
      }

      game.startHunterGame(mapJson, 1);
      final rotaEquipe1 = coletarRota();
      game.resetGame();

      game.startHunterGame(mapJson, 2);
      final rotaEquipe2 = coletarRota();

      // Ambas têm as 3 pistas
      expect(rotaEquipe1.length, 3);
      expect(rotaEquipe2.length, 3);
      expect(rotaEquipe1.keys.toSet(), rotaEquipe2.keys.toSet());

      // Pistas com 2 versículos: equipes 1 e 2 recebem versículos diferentes
      expect(rotaEquipe1['PAO'], isNot(rotaEquipe2['PAO']));
      expect(rotaEquipe1['AGUA'], isNot(rotaEquipe2['AGUA']));
      // LUZ tem 1 versículo só: ambas recebem o mesmo
      expect(rotaEquipe1['LUZ'], rotaEquipe2['LUZ']);
    });

    test('Rota da mesma equipe é determinística (mesma seed)', () {
      final game = GameProvider();
      final mapJson = jsonEncode(buildProject().toJson());

      game.startHunterGame(mapJson, 3);
      final ordem1 = List.generate(game.totalClues, (i) {
        final k = game.currentClue['k'];
        game.validateQr(CryptoUtil.toAlphanumeric(k!));
        return k;
      });
      game.resetGame();

      game.startHunterGame(mapJson, 3);
      final ordem2 = List.generate(game.totalClues, (i) {
        final k = game.currentClue['k'];
        game.validateQr(CryptoUtil.toAlphanumeric(k!));
        return k;
      });

      expect(ordem1, ordem2);
    });

    test('Fluxo completo: acertos avançam e término dispara vitória', () {
      final game = GameProvider();
      final p = buildProject();
      final mapJson = jsonEncode(p.toJson());

      expect(game.startHunterGame(mapJson, 1), isTrue);
      expect(game.status, GameStatus.playing);

      // Acerta todas as pistas usando a cifra Gematria
      for (int i = 0; i < game.totalClues; i++) {
        final keyword = game.currentClue['k']!;
        game.validateQr(CryptoUtil.toAlphanumeric(keyword));
        // Se não terminou, avançou de pista
        if (i < game.totalClues - 1) {
          expect(game.status, GameStatus.playing);
        }
      }
      expect(game.status, GameStatus.finished);
    });

    test('Erro no QR dispara Selo Preto (bloqueio)', () {
      final game = GameProvider();
      final mapJson = jsonEncode(buildProject().toJson());

      game.startHunterGame(mapJson, 1);
      game.validateQr('999999');
      expect(game.status, GameStatus.locked);

      // Perdão inválido não destrava
      game.applyPardon('XXXXYYYY');
      expect(game.status, GameStatus.locked);

      // Perdão válido destrava
      game.applyPardon(''); // será preenchido abaixo com token real
    });

    test('peekTeamCount extrai o número de equipes do mapa', () {
      final game = GameProvider();
      final mapJson = jsonEncode(buildProject().toJson());
      expect(game.peekTeamCount(mapJson), 4);
      expect(game.peekTeamCount('lixo'), isNull);
    });

    test('Mapa inválido retorna false ao iniciar', () {
      final game = GameProvider();
      expect(game.startHunterGame('nao é json', 1), isFalse);
    });
  });

  group('Project/Clue - serialização', () {
    test('toJson/fromJson preserva dados', () {
      final original = buildProject();
      final json = original.toJson();
      final restored = Project.fromJson(json);

      expect(restored.name, original.name);
      expect(restored.teamCount, original.teamCount);
      expect(restored.clues.length, original.clues.length);
      expect(restored.clues[0].keyword, 'PAO');
      expect(restored.clues[0].verses, ['João 6:35', 'Êxodo 16:4']);
    });

    test('IDs são únicos entre instâncias', () {
      final a = Clue(keyword: 'A', verses: ['x']);
      final b = Clue(keyword: 'B', verses: ['y']);
      expect(a.id, isNot(b.id));
    });
  });
}

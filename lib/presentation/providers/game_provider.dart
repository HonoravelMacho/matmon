import 'package:flutter/material.dart';
import '../../domain/entities/clue.dart';
import '../../core/utils/crypto_util.dart';

enum GameStatus { waitingBlessing, playing, locked, finished }

class GameProvider with ChangeNotifier {
  List<Clue> _route = [];
  int _currentIndex = 0;
  GameStatus _status = GameStatus.waitingBlessing;
  bool _isJesusNominated = false;

  GameStatus get status => _status;
  bool get isJesusNominated => _isJesusNominated;
  int get progress => _currentIndex;
  int get totalClues => _route.length;
  Clue get currentClue => _route.isNotEmpty ? _route[_currentIndex] : Clue(id: '0', verseText: 'Aguardando Mapa...', reference: '', keyword: '');

  // O Organizador nomeia Jesus
  void nominateStaff() {
    _isJesusNominated = true;
    notifyListeners();
  }

  // Jesus entrega o Mapa ao Caçador e abençoa o início
  void startWithBlessing(List<Clue> receivedMap) {
    _route = receivedMap;
    _currentIndex = 0;
    _status = GameStatus.playing;
    notifyListeners();
  }

  // Validação com a cifra alfanumérica
  void validateQr(String scannedData) {
    if (_status != GameStatus.playing) return;

    // Converte a palavra-chave da pista atual para a cifra (ex: LUZ -> 122126)
    String encryptedKey = CryptoUtil.toAlphanumeric(currentClue.keyword);

    if (scannedData == encryptedKey) {
      _currentIndex++;
      if (_currentIndex >= _route.length) {
        _status = GameStatus.finished;
      }
    } else {
      _status = GameStatus.locked; // SELO PRETO
    }
    notifyListeners();
  }

  // Jesus concede o Perdão (Selo Vermelho)
  void receivePardon(String pardonToken) {
    // Se o token for válido (baseado no tempo/staff)
    if (pardonToken.isNotEmpty) {
      _status = GameStatus.playing;
      notifyListeners();
    }
  }
}

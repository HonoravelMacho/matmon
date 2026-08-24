import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtil {
  static const int periodSeconds = 15; // Janela TOTP: 15 segundos

  // Converte texto para cifra posicional A=1, B=2 ... Z=26 (Gematria Alfanumérica)
  // Trata acentos (Á->A) e Ç->C antes da conversão.
  static String toAlphanumeric(String input) {
    String normalized = input
        .toUpperCase()
        .replaceAll(RegExp(r'[ÁÀÂÃÄ]'), 'A')
        .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
        .replaceAll(RegExp(r'[ÍÌÎÏ]'), 'I')
        .replaceAll(RegExp(r'[ÓÒÔÕÖ]'), 'O')
        .replaceAll(RegExp(r'[ÚÙÛÜ]'), 'U')
        .replaceAll('Ç', 'C');

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < normalized.length; i++) {
      int code = normalized.codeUnitAt(i);
      // 'A' na tabela ASCII é 65, então diminuindo 64 vira 1 (A=1, B=2...)
      if (code >= 65 && code <= 90) {
        buffer.write((code - 64).toString());
      } else if (normalized[i] != ' ') {
        buffer.write(normalized[i]);
      }
    }
    return buffer.toString();
  }

  // Gera o token do Perdão para um período específico (TOTP de 15s)
  static String tokenForPeriod(int period) {
    var bytes = utf8.encode("MATMON_JESUS_$period");
    return sha256.convert(bytes).toString().substring(0, 8).toUpperCase();
  }

  // Token atual do Staff (Jesus)
  static String generateStaffToken() {
    int period = DateTime.now().millisecondsSinceEpoch ~/ (periodSeconds * 1000);
    return tokenForPeriod(period);
  }

  // Valida o token aceitando a janela atual e a anterior (+/- 1 período).
  // Assim, se o Caçador colar o código alguns segundos depois, ainda funciona.
  static bool verifyPardonToken(String input) {
    final cleaned = input.trim().toUpperCase();
    if (cleaned.isEmpty || cleaned.length != 8) return false;
    int current = DateTime.now().millisecondsSinceEpoch ~/ (periodSeconds * 1000);
    for (int offset = -1; offset <= 1; offset++) {
      if (tokenForPeriod(current + offset) == cleaned) return true;
    }
    return false;
  }
}

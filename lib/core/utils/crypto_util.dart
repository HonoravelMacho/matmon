import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtil {
  static String generateStaffToken() {
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 15000;
    var bytes = utf8.encode("MATMON_JESUS_$timestamp");
    return sha256.convert(bytes).toString().substring(0, 8).toUpperCase();
  }

  // Converte texto para cifra posicional A=1, B=2 ... Z=26 (Gematria Alfanumérica)
  static String toAlphanumeric(String input) {
    String normalized = input.toUpperCase()
        .replaceAll(RegExp(r'[ÁÀÂÃÄ]'), 'A')
        .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
        .replaceAll(RegExp(r'[ÍÌÎÏ]'), 'I')
        .replaceAll(RegExp(r'[ÓÒÔÕÖ]'), 'O')
        .replaceAll(RegExp(r'[ÚÙÛÜ]'), 'U')
        .replaceAll(RegExp(r'[Ç]'), 'C');

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < normalized.length; i++) {
      int code = normalized.codeUnitAt(i);
      // 'A' na tabela ASCII é 65, então diminuindo 64 vira 1 (A=1, B=2...)
      if (code >= 65 && code <= 90) {
        buffer.write((code - 64).toString());
      } else {
        buffer.write(normalized[i]);
      }
    }
    return buffer.toString();
  }
}

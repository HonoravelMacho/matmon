import 'package:flutter_test/flutter_test.dart';
import 'package:matmon/core/utils/crypto_util.dart';

void main() {
  group('CryptoUtil.toAlphanumeric (Cifra Gematria)', () {
    test('PAO vira 16115', () {
      expect(CryptoUtil.toAlphanumeric('PAO'), '16115');
    });

    test('Trata acentos: ÁGUA vira 17211', () {
      // A=1, G=7, U=21, A=1
      expect(CryptoUtil.toAlphanumeric('ÁGUA'), '17211');
    });

    test('Trata Ç: CORAÇAO vira 3151813115', () {
      // C=3 O=15 R=18 A=1 Ç->C=3 A=1 O=15
      expect(CryptoUtil.toAlphanumeric('CORAÇAO'), '3151813115');
    });

    test('Minúsculas e espaços são tratados', () {
      // P=16 A=1 O=15 D=4 E=5 M=13 E=5 L=12
      expect(CryptoUtil.toAlphanumeric('pao de mel'), '161154513512');
    });

    test('Palavra vazia retorna vazio', () {
      expect(CryptoUtil.toAlphanumeric(''), '');
    });
  });

  group('CryptoUtil TOTP do Perdão', () {
    test('Token atual é válido', () {
      final token = CryptoUtil.generateStaffToken();
      expect(CryptoUtil.verifyPardonToken(token), isTrue);
    });

    test('Token do período anterior ainda é aceito (tolerância)', () {
      final period = DateTime.now().millisecondsSinceEpoch ~/ 15000;
      final oldToken = CryptoUtil.tokenForPeriod(period - 1);
      expect(CryptoUtil.verifyPardonToken(oldToken), isTrue);
    });

    test('Token inválido é rejeitado', () {
      expect(CryptoUtil.verifyPardonToken('ABCD1234'), isFalse);
      expect(CryptoUtil.verifyPardonToken(''), isFalse);
      expect(CryptoUtil.verifyPardonToken('123'), isFalse);
    });

    test('Token é case-insensitive e ignora espaços', () {
      final token = CryptoUtil.generateStaffToken();
      expect(CryptoUtil.verifyPardonToken(' ${token.toLowerCase()} '), isTrue);
    });

    test('Token tem 8 caracteres alfanuméricos maiúsculos', () {
      final token = CryptoUtil.generateStaffToken();
      expect(token.length, 8);
      expect(RegExp(r'^[A-Z0-9]+$').hasMatch(token), isTrue);
    });
  });
}

import 'dart:convert';
import 'package:crypto/crypto.dart';
class CryptoUtil {
  static String generateStaffToken() {
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 15000;
    var bytes = utf8.encode("MATMON_JESUS_$timestamp");
    return sha256.convert(bytes).toString().substring(0, 8).toUpperCase();
  }
}
import 'dart:convert';

import 'package:crypto/crypto.dart';

class Encrypption {
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate a Random Session Token
  static String generateToken(int userId) {
    return sha256
        .convert(
            utf8.encode("$userId-${DateTime.now().millisecondsSinceEpoch}"))
        .toString();
  }
}

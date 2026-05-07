import 'dart:convert';

import 'package:crypto/crypto.dart';

class CryptoUtils {
  CryptoUtils._();

  // encripta la contraseña usando SHA-256 con salt
  static String hashPassword(String password) {
    // salt statico
    const salt = 'shopflow_s@lt_2024';
    final saltedPassword = '$salt$password$salt';
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verifica si la constraseña coincide con el hash
  static bool verifyPassword(String password, String hashedPassword) {
    return hashPassword(password) == hashedPassword;
  }
}
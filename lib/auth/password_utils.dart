import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Hashes a password using SHA-256. For production, use bcrypt or argon2.
String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

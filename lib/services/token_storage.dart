import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _keyToken = 'jwt_token';
  static const _keyNombre = 'user_nombre';
  static const _keyEmail = 'user_email';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveSession({
    required String token,
    required String nombre,
    required String email,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyNombre, value: nombre);
    await _storage.write(key: _keyEmail, value: email);
  }

  Future<String?> getToken() => _storage.read(key: _keyToken);

  Future<String?> getNombre() => _storage.read(key: _keyNombre);

  Future<String?> getEmail() => _storage.read(key: _keyEmail);

  Future<void> clearSession() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyNombre);
    await _storage.delete(key: _keyEmail);
  }

  static DateTime? decodeExpiration(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is num) {
        return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static bool isTokenExpired(String token) {
    final exp = decodeExpiration(token);
    if (exp == null) return true;
    return !exp.isAfter(DateTime.now());
  }
}

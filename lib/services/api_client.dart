import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_storage.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Sesión expirada, vuelve a iniciar sesión']);

  @override
  String toString() => message;
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final TokenStorage tokenStorage;
  final http.Client _client;

  ApiClient({
    required this.tokenStorage,
    http.Client? client,
  }) : _client = client ?? http.Client();

  static Uri _buildUri(String path) {
    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base$path');
  }

  Future<http.Response> get(String path) async {
    final headers = await _authHeaders();
    final response = await _client
        .get(_buildUri(path), headers: headers)
        .timeout(const Duration(seconds: 15));
    await _handleUnauthorized(response);
    return response;
  }

  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    final headers = withAuth
        ? await _authHeaders()
        : {'Content-Type': 'application/json'};
    final response = await _client
        .post(
          _buildUri(path),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (withAuth) {
      await _handleUnauthorized(response);
    }
    return response;
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final response = await _client
        .put(
          _buildUri(path),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    await _handleUnauthorized(response);
    return response;
  }

  Future<http.Response> delete(String path) async {
    final headers = await _authHeaders();
    final response = await _client
        .delete(_buildUri(path), headers: headers)
        .timeout(const Duration(seconds: 15));
    await _handleUnauthorized(response);
    return response;
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await tokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _handleUnauthorized(http.Response response) async {
    if (response.statusCode == 401) {
      await tokenStorage.clearSession();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
        arguments: 'Sesión expirada, vuelve a iniciar sesión',
      );
      throw UnauthorizedException();
    }
  }

  static String extractErrorMessage(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['error'] is String) {
          return decoded['error'] as String;
        }
        if (decoded['errores'] is Map<String, dynamic>) {
          final errores = decoded['errores'] as Map<String, dynamic>;
          return errores.values.join('\n');
        }
      }
    } catch (_) {}
    return fallback;
  }
}

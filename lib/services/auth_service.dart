import 'dart:convert';
import '../models/auth_response.dart';
import 'api_client.dart';
import 'token_storage.dart';

class AuthService {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthService({
    required this.apiClient,
    required this.tokenStorage,
  });

  Future<AuthResponse> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/register',
      {
        'nombre': nombre.trim(),
        'email': email.trim(),
        'password': password,
      },
      withAuth: false,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final auth = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await tokenStorage.saveSession(
        token: auth.token,
        nombre: auth.nombre,
        email: auth.email,
      );
      return auth;
    }

    throw ApiException(
      response.statusCode,
      ApiClient.extractErrorMessage(response, 'Error al registrar usuario'),
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/login',
      {
        'email': email.trim(),
        'password': password,
      },
      withAuth: false,
    );

    if (response.statusCode == 200) {
      final auth = AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await tokenStorage.saveSession(
        token: auth.token,
        nombre: auth.nombre,
        email: auth.email,
      );
      return auth;
    }

    throw ApiException(
      response.statusCode,
      ApiClient.extractErrorMessage(response, 'Credenciales inválidas'),
    );
  }

  Future<void> logout() => tokenStorage.clearSession();
}

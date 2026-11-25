class AuthResponse {
  final String token;
  final String nombre;
  final String email;

  const AuthResponse({
    required this.token,
    required this.nombre,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      nombre: json['nombre'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

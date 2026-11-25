import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestacontrol_app/screens/login_screen.dart';
import 'package:prestacontrol_app/services/api_client.dart';
import 'package:prestacontrol_app/services/auth_service.dart';
import 'package:prestacontrol_app/services/token_storage.dart';

void main() {
  testWidgets('LoginScreen muestra formulario de inicio de sesión', (tester) async {
    final storage = TokenStorage();
    final apiClient = ApiClient(tokenStorage: storage);
    final authService = AuthService(apiClient: apiClient, tokenStorage: storage);

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(authService: authService),
      ),
    );

    expect(find.text('Acceso de prestamista'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('¿No tienes cuenta? Regístrate aquí'), findsOneWidget);
  });
}

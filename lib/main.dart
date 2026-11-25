import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/prestamos_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/prestamo_service.dart';
import 'services/token_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage: tokenStorage);
  final authService = AuthService(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  final prestamoService = PrestamoService(apiClient: apiClient);

  runApp(
    PrestaControlApp(
      tokenStorage: tokenStorage,
      authService: authService,
      prestamoService: prestamoService,
    ),
  );
}

class PrestaControlApp extends StatelessWidget {
  final TokenStorage tokenStorage;
  final AuthService authService;
  final PrestamoService prestamoService;

  const PrestaControlApp({
    super.key,
    required this.tokenStorage,
    required this.authService,
    required this.prestamoService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrestaControl',
      debugShowCheckedModeBanner: false,
      navigatorKey: ApiClient.navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => SplashScreen(tokenStorage: tokenStorage),
        '/login': (_) => LoginScreen(authService: authService),
        '/register': (_) => RegisterScreen(authService: authService),
        '/prestamos': (_) => PrestamosScreen(
              prestamoService: prestamoService,
              authService: authService,
              tokenStorage: tokenStorage,
            ),
      },
    );
  }
}

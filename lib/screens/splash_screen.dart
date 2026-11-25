import 'package:flutter/material.dart';
import '../services/token_storage.dart';

class SplashScreen extends StatefulWidget {
  final TokenStorage tokenStorage;

  const SplashScreen({super.key, required this.tokenStorage});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await widget.tokenStorage.getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty && !TokenStorage.isTokenExpired(token)) {
      Navigator.of(context).pushReplacementNamed('/prestamos');
    } else {
      if (token != null) {
        await widget.tokenStorage.clearSession();
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 64),
            SizedBox(height: 16),
            Text(
              'PrestaControl',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:Sante/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await ApiService.getToken();

    if (token != null) {
      Navigator.pushReplacementNamed(context, '/home'); // ✅ Auto-login
    } else {
      Navigator.pushReplacementNamed(context, '/'); // ⛔ Pas de token : login
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4F46E5),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text("Chargement...", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

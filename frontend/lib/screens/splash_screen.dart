import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../constants/routes.dart'; // 💡 Recommande d'utiliser un fichier routes.dart centralisé

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final auth = Provider.of<AuthController>(context, listen: false);

    try {
      // 🔄 Vérifie l'état de connexion (token)
      await auth.initialize();

      // ⏳ Petit délai visuel (Splash effect)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // 🚦 Redirection automatique
      if (auth.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4F46E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_heart, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'SantéTrack',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

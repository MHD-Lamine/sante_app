import 'package:flutter/material.dart';
import 'package:Sante/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final success = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _loading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/home'); // 🔁 Redirection vers accueil
    } else {
      setState(() {
        _errorMessage = 'Email ou mot de passe incorrect.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bienvenue 👋", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loading ? null : _login,
              icon: const Icon(Icons.login),
              label: _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text("Se connecter"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF4F46E5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

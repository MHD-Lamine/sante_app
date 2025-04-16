import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/AuthController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _submit() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final success = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        return Scaffold(
          appBar: AppBar(title: const Text("Connexion")),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Mot de passe"),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                if (auth.error != null)
                  Text(auth.error!, style: const TextStyle(color: Colors.red)),

                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Se connecter"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

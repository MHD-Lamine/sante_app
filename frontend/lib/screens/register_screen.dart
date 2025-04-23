import 'package:Sante/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthController>(context, listen: false);
    final success = await auth.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Inscription"),
            backgroundColor: const Color(0xFF4F46E5),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    "Créer un compte",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Entrez vos informations pour commencer",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Nom complet",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Nom requis" : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value == null || !value.contains('@')
                            ? "Email invalide"
                            : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "Mot de passe",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                        value == null || value.length < 4
                            ? "Mot de passe trop court"
                            : null,
                  ),
                  const SizedBox(height: 24),

                  if (auth.error != null)
                    Text(auth.error!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14)),

                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("S'inscrire",
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text("Déjà un compte ? Se connecter"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
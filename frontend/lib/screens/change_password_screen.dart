import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Sante/services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  String? message;
  bool loading = false;

  Future<void> _submit() async {
    final token = await ApiService.getToken();

    setState(() {
      loading = true;
      message = null;
    });

    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/change_password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'old_password': _oldPasswordCtrl.text,
        'new_password': _newPasswordCtrl.text,
      }),
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      setState(() => message = "✅ Mot de passe mis à jour !");
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else {
      final error = jsonDecode(response.body);
      setState(() => message = "❌ ${error["msg"] ?? "Erreur inconnue"}");
    }
  }

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Changer le mot de passe")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _oldPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mot de passe actuel"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Nouveau mot de passe"),
            ),
            const SizedBox(height: 24),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color: message!.startsWith("✅") ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Mettre à jour"),
            ),
          ],
        ),
      ),
    );
  }
}

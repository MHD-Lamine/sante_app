import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Sante/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? message;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await ApiService.getToken();
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _nameCtrl.text = data['name'];
        _emailCtrl.text = data['email'];
      });
    }
  }

  Future<void> _updateProfile() async {
    final token = await ApiService.getToken();
    setState(() {
      loading = true;
      message = null;
    });

    final body = {
      "name": _nameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
    };

    if (_passwordCtrl.text.isNotEmpty) {
      body["password"] = _passwordCtrl.text;
    }

    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      setState(() {
        message = "✅ Profil mis à jour avec succès !";
      });

      // Retour après un délai
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context, true); // retour vers ProfileScreen
      });
    } else {
      setState(() {
        message = "❌ Erreur : ${response.statusCode}";
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier le profil")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: "Nouveau mot de passe (facultatif)"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color: message!.startsWith("✅") ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : _updateProfile,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}

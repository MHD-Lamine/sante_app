import 'dart:convert';
import 'package:Sante/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  String? errorMessage;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final token = await ApiService.getToken();

    if (token == null) {
      setState(() {
        errorMessage = "Aucun token trouvé. Veuillez vous reconnecter.";
        loading = false;
      });
      return;
    }

    // ✅ AUCUN Content-Type ici, car c’est un GET sans body
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json', // ✅ PAS Content-Type !
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userData = jsonDecode(response.body);
        loading = false;
      });
    } else {
      print('Erreur /profile : ${response.statusCode} — ${response.body}');
      setState(() {
        errorMessage = "Erreur : ${response.statusCode}";
        loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profil")),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Déconnexion",
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nom : ${userData?['name']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Email : ${userData?['email']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Rôle : ${userData?['role']}", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

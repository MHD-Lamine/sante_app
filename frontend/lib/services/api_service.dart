import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000'; // à adapter selon l’environnement
  static final storage = FlutterSecureStorage();

  /// 🔐 Connexion utilisateur
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'token', value: data['access_token']);
        await storage.write(key: 'user_id', value: data['user_id'].toString());
        return true;
      } else {
        print('Erreur login : ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur de connexion : $e');
      return false;
    }
  }

  /// ✅ Lire le token stocké
  static Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  /// ✅ Lire l’ID utilisateur
  static Future<String?> getUserId() async {
    return await storage.read(key: 'user_id');
  }

  /// 🔓 Déconnexion
  static Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'user_id');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000'; //  IP en debug
  static final storage = FlutterSecureStorage();

  /// 🔐 Login utilisateur : email + mot de passe
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

        // ✅ Stocker le token JWT en local
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

  /// 🔐 Obtenir le token stocké
  static Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  /// 🔐 Supprimer le token (logout)
  static Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'user_id');
  }
}

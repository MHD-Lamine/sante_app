import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000';
  static final storage = FlutterSecureStorage();

  // 🔐 Obtenir le token JWT
  static Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  // 🔐 Obtenir l'ID utilisateur
  static Future<int?> getUserId() async {
    final userId = await storage.read(key: 'user_id');
    return userId != null ? int.tryParse(userId) : null;
  }

  // 🔐 Connexion utilisateur
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
        await storage.write(key: 'user_name', value: data['name']);
        return true;
      } else {
        print("Erreur login : ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erreur connexion : $e");
      return false;
    }
  }

  // 🔐 Déconnexion
  static Future<void> logout() async {
    await storage.deleteAll();
  }

  // 📊 Récupérer les mesures pour un utilisateur
  static Future<List<dynamic>> fetchMeasures(int userId) async {
    final token = await getToken();
    if (token == null) throw Exception("Token manquant");

    final url = Uri.parse('$baseUrl/measures/$userId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur fetch measures : ${response.statusCode} ${response.body}");
    }
  }

  // 👤 Récupérer le nom de l'utilisateur depuis l'API
  static Future<String?> getUserName() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'];
    } else {
      print("Erreur récupération nom : ${response.statusCode}");
      return null;
    }
  }

  // 👤 Lire le nom de l'utilisateur depuis le stockage local
  static Future<String?> getUserNameFromStorage() async {
    return await storage.read(key: 'user_name');
  }

  // 🔁 Récupérer les infos complètes du profil
  static Future<Map<String, dynamic>> fetchProfile() async {
    final token = await getToken();
    if (token == null) throw Exception("Token manquant");

    final url = Uri.parse('$baseUrl/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur profil : ${response.statusCode}");
    }
  }

  static Future<bool> updateProfile(Map<String, dynamic> data) async {
  final token = await getToken();
  if (token == null) throw Exception("Token manquant");

  final url = Uri.parse('$baseUrl/profile');
  final response = await http.put(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  return response.statusCode == 200;
}

}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Sante/models/health_tip.dart';
import 'package:Sante/models/medication.dart';
import 'package:Sante/models/appointment.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000'; // Android Emulator
  static final storage = FlutterSecureStorage();

  // === 🔐 Token storage
  static Future<String?> getToken() async => await storage.read(key: 'access_token');
  static Future<String?> getRefreshToken() async => await storage.read(key: 'refresh_token');
  static Future<String?> getUserNameFromStorage() async => await storage.read(key: 'user_name');

  static Future<void> logout() async => await storage.deleteAll();

  static Future<void> resetAuth() async {
    print("🔁 Réinitialisation des jetons...");
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'user_name');
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.trim().split(".").length == 3;
  }

  // === 🔐 Register
  static Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': 'patient',
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Erreur register : $e");
      return false;
    }
  }

  // === 🔐 Login
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'access_token', value: data['access_token']);
        await storage.write(key: 'refresh_token', value: data['refresh_token']);
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

  // === 🔁 Refresh token
  static Future<void> refreshAccessToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null || refresh.trim().split(".").length != 3) {
      await resetAuth();
      throw Exception("Jeton de rafraîchissement invalide.");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/refresh'),
      headers: {
        'Authorization': 'Bearer $refresh',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['access_token']);
    } else {
      await resetAuth();
      throw Exception("Échec du rafraîchissement. Veuillez vous reconnecter.");
    }
  }

  // === 🔐 GET sécurisé avec refresh auto
  static Future<http.Response> getSecure(String endpoint) async {
    var token = await getToken();
    if (token == null || token.trim().split(".").length != 3) {
      await resetAuth();
      throw Exception("Token JWT invalide ou corrompu.");
    }

    var response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401 && response.body.contains("expired")) {
      await refreshAccessToken();
      token = await getToken();
      response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
    }

    return response;
  }

  // === 👤 Profil
  static Future<Map<String, dynamic>> fetchProfile() async {
    final response = await getSecure('/profile');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur profil : ${response.statusCode}");
    }
  }

  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    final token = await getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  // === 📏 Mesures
  static Future<List<dynamic>> fetchMeasures() async {
    final response = await getSecure('/measures');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur mesures : ${response.statusCode}");
    }
  }

  // === 💊 Médicaments
  static Future<List<Medication>> fetchTodayMedications() async {
    final response = await getSecure('/medications');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Medication.fromJson(json)).toList();
    } else {
      throw Exception("Erreur médicaments : ${response.body}");
    }
  }

  static Future<bool> takeSchedule(int scheduleId) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/medications/schedules/$scheduleId/take'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }

  // === 📅 Rendez-vous
  static Future<List<Appointment>> fetchUpcomingAppointments() async {
    final response = await getSecure('/appointments');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception("Erreur rendez-vous : ${response.statusCode}");
    }
  }

  // === 🧠 Conseils santé
  static Future<List<HealthTip>> fetchHealthTips() async {
    final response = await getSecure('/healthtips');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => HealthTip.fromJson(e)).toList();
    } else {
      throw Exception("Erreur santé : ${response.statusCode}");
    }
  }

  // === POST générique
  static Future<void> post(String endpoint, Map<String, dynamic> data) async {
    var token = await getToken();
    if (token == null || token.trim().split(".").length != 3) {
      await resetAuth();
      throw Exception("Token JWT invalide ou manquant.");
    }

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode >= 400) {
      throw Exception("Erreur POST $endpoint : ${response.body}");
    }
  }
}

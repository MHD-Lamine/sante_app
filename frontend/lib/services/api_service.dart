import 'dart:convert';
import 'package:Sante/models/health_tip.dart';
import 'package:Sante/models/medication.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Sante/models/appointment.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000';
  static final storage = FlutterSecureStorage();

  // === Authentification ===
  static Future<String?> getToken() async => await storage.read(key: 'token');

  static Future<int?> getUserId() async {
    final userId = await storage.read(key: 'user_id');
    return userId != null ? int.tryParse(userId) : null;
  }

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

  static Future<void> logout() async => await storage.deleteAll();

  // === Utilisateur ===
  static Future<String?> getUserNameFromStorage() async =>
      await storage.read(key: 'user_name');

  static Future<String?> getUserName() async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'];
    } else {
      print("Erreur récupération nom : ${response.statusCode}");
      return null;
    }
  }

  static Future<Map<String, dynamic>> fetchProfile() async {
    final token = await getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
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

  // === Mesures ===
  static Future<List<dynamic>> fetchMeasures(int userId) async {
    final token = await getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.get(
      Uri.parse('$baseUrl/measures/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur fetch measures : ${response.statusCode} ${response.body}");
    }
  }

  // === Médicaments & horaires ===
  static Future<List<Medication>> fetchTodayMedications(int userId) async {
    final token = await getToken();
    if (token == null) throw Exception("Token manquant");

    final response = await http.get(
      Uri.parse('$baseUrl/medications/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Medication.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des médicaments : ${response.body}');
    }
  }

  /// ✅ Marquer UNE prise (schedule) comme faite
  static Future<bool> takeSchedule(int scheduleId) async {
    final token = await getToken();
    if (token == null) {
      print("❌ Token manquant pour PUT /medications/schedules/$scheduleId/take");
      return false;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/medications/schedules/$scheduleId/take'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("🔁 Réponse takeSchedule($scheduleId): ${response.statusCode} - ${response.body}");

    return response.statusCode == 200;
  }

  static Future<List<Appointment>> fetchUpcomingAppointments() async {
  final token = await getToken();
  final userId = await getUserId();

  if (token == null || userId == null) {
    throw Exception("Token ou ID utilisateur manquant");
  }

  final response = await http.get(
    Uri.parse('$baseUrl/appointments/$userId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((item) => Appointment.fromJson(item)).toList();
  } else {
    throw Exception('Erreur lors du chargement des rendez-vous');
  }
}

// 📘 Récupérer les conseils santé depuis l'API
static Future<List<HealthTip>> fetchHealthTips() async {
  final token = await getToken();
  if (token == null) throw Exception("Token manquant");

  final url = Uri.parse('$baseUrl/healthtips');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List jsonData = jsonDecode(response.body);
    return jsonData.map((e) => HealthTip.fromJson(e)).toList();
  } else {
    throw Exception("Erreur fetch health tips : ${response.statusCode}");
  }

}

static Future<void> post(String endpoint, Map<String, dynamic> data) async {
  final token = await getToken();
  final response = await http.post(
    Uri.parse('$baseUrl$endpoint'),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(data),
  );
  if (response.statusCode >= 400) {
    throw Exception("Erreur : ${response.body}");
  }
}


  
}

import 'package:flutter/material.dart';
import 'package:Sante/services/api_service.dart';

class AuthController with ChangeNotifier {
  bool isLoading = false;
  String? token;
  int? userId;
  String? userName;

  String? error;

  /// 🔐 Connexion utilisateur
  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final success = await ApiService.login(email, password);

    if (success) {
      token = await ApiService.getToken();
      userId = await ApiService.getUserId();
      userName = await ApiService.getUserNameFromStorage();
    } else {
      error = "Email ou mot de passe incorrect.";
    }

    isLoading = false;
    notifyListeners();
    return success;
  }

  /// 🔐 Déconnexion
  Future<void> logout() async {
    await ApiService.logout();
    token = null;
    userId = null;
    userName = null;
    notifyListeners();
  }

  /// 🧠 Initialisation depuis le stockage
  Future<void> initialize() async {
    token = await ApiService.getToken();
    userId = await ApiService.getUserId();
    userName = await ApiService.getUserNameFromStorage();
    notifyListeners();
  }

  bool get isAuthenticated => token != null;
}

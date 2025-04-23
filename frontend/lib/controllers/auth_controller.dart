import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthController with ChangeNotifier {
  bool isLoading = false;
  String? error;
  bool isAuthenticated = false;

  /// 🔄 Initialisation au démarrage (SplashScreen)
  Future<void> initialize() async {
    try {
      isAuthenticated = await ApiService.isAuthenticated();
    } catch (_) {
      await ApiService.resetAuth();
      isAuthenticated = false;
    }
    notifyListeners();
  }

  /// 🔐 Connexion
  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await ApiService.login(email, password);
      isAuthenticated = success;

      if (!success) {
        error = "Email ou mot de passe invalide.";
      }

      return success;
    } catch (e) {
      error = "Erreur lors de la connexion.";
      isAuthenticated = false;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 📝 Inscription
  Future<bool> register(String name, String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await ApiService.register(name, email, password);
      return success;
    } catch (e) {
      error = "Erreur lors de l'inscription.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔓 Déconnexion
  Future<void> logout() async {
    await ApiService.resetAuth();
    isAuthenticated = false;
    notifyListeners();
  }

  /// 🧼 Nettoyage d'erreur
  void clearError() {
    error = null;
    notifyListeners();
  }
}

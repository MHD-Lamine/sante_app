import 'package:flutter/material.dart';
import 'package:Sante/services/api_service.dart';

class UserController with ChangeNotifier {
  bool isLoading = false;
  String? error;

  int? id;
  String? name;
  String? email;
  String? role;

  /// Charger le profil utilisateur depuis l'API
  Future<void> loadProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await ApiService.fetchProfile();
      id = data['id'];
      name = data['name'];
      email = data['email'];
      role = data['role'];
    } catch (e) {
      error = "Erreur chargement profil : $e";
    }

    isLoading = false;
    notifyListeners();
  }

  /// Mettre à jour les données du profil
  Future<bool> updateProfile(String newName, String newEmail) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await ApiService.updateProfile({
        "name": newName,
        "email": newEmail,
      });

      if (success) {
        name = newName;
        email = newEmail;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = "Échec de la mise à jour.";
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      error = "Erreur mise à jour : $e";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

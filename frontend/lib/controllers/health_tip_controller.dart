import 'package:flutter/material.dart';
import '../models/health_tip.dart';
import '../services/api_service.dart';

class HealthTipController extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<HealthTip> tips = [];

  // 🔄 Récupère les conseils santé
  Future<void> fetchTips() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      tips = await ApiService.fetchHealthTips();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // 🔁 Rafraîchissement manuel
  Future<void> refresh() async {
    await fetchTips();
  }
}

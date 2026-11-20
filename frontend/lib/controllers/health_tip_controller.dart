import 'package:flutter/material.dart';
import '../models/health_tip.dart';
import '../services/api_service.dart';

class HealthTipController extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  HealthTip? tip;

  // 🔄 Récupère le conseil choisi selon les dernières mesures du patient
  Future<void> fetchTips() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      tip = await ApiService.fetchRecommendedTip();
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

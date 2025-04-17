import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/medication_schedule.dart';
import '../services/api_service.dart';

class MedicationController with ChangeNotifier {
  bool isLoading = false;
  String? error;

  List<Medication> todayMedications = [];

  /// 🔄 Charger tous les médicaments + leurs prises du jour
  Future<void> loadTodayMedications() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final userId = await ApiService.getUserId();
      if (userId == null) throw Exception("Utilisateur non connecté");

      todayMedications = await ApiService.fetchTodayMedications(userId);
    } catch (e) {
      error = "Erreur chargement médicaments : $e";
    }

    isLoading = false;
    notifyListeners();
  }

  /// ✅ Marquer une prise horaire comme prise (schedules)
  Future<void> markScheduleAsTaken(int medId, int scheduleId) async {
    final success = await ApiService.takeSchedule(scheduleId);
    if (!success) return;

    // Mise à jour locale (optimiste)
    final medIndex = todayMedications.indexWhere((m) => m.id == medId);
    if (medIndex != -1) {
      final medication = todayMedications[medIndex];
      final updatedSchedules = medication.schedules.map((s) {
        if (s.id == scheduleId) {
          return s.copyWith(taken: true);
        }
        return s;
      }).toList();

      todayMedications[medIndex] = medication.copyWith(schedules: updatedSchedules);
      notifyListeners();
    }
  }
}

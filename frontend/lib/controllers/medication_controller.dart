import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/medication_schedule.dart';
import '../services/api_service.dart';

/// Une prise précise d'un médicament aujourd'hui
class DoseSlot {
  final Medication medication;
  final MedicationSchedule schedule;
  final DateTime time;

  DoseSlot(this.medication, this.schedule, this.time);
}

class MedicationController with ChangeNotifier {
  bool isLoading = false;
  String? error;

  List<Medication> todayMedications = [];

  /// Toutes les prises du jour, triées par heure
  List<DoseSlot> get _todaySlots {
    final slots = <DoseSlot>[];
    for (final med in todayMedications) {
      for (final sched in med.schedules) {
        final time = sched.scheduledToday();
        if (time != null) slots.add(DoseSlot(med, sched, time));
      }
    }
    slots.sort((a, b) => a.time.compareTo(b.time));
    return slots;
  }

  /// Prises à afficher maintenant (dans leur fenêtre de prise)
  List<DoseSlot> get currentDoses =>
      _todaySlots.where((d) => d.schedule.isVisibleNow()).toList();

  /// Prochaines prises (toutes celles de la prochaine heure prévue),
  /// utilisées quand aucune prise n'est en cours
  List<DoseSlot> get nextDoses {
    final now = DateTime.now();
    final upcoming = _todaySlots.where((d) => d.time.isAfter(now)).toList();
    if (upcoming.isEmpty) return [];
    final nextTime = upcoming.first.time;
    return upcoming.where((d) => d.time == nextTime).toList();
  }

  /// 🔄 Charger tous les médicaments + leurs prises du jour
  Future<void> loadTodayMedications() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      todayMedications = await ApiService.fetchTodayMedications();
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

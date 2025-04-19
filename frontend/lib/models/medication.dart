import 'medication_schedule.dart';
import 'package:intl/intl.dart';

class Medication {
  final int id;
  final String name;
  final String dosage;
  final String? note;
  final List<MedicationSchedule> schedules;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    this.note,
    required this.schedules,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'] ?? '',
      note: json['note'],
      schedules: (json['schedules'] as List)
          .map((s) => MedicationSchedule.fromJson(s))
          .toList(),
    );
  }

  Medication copyWith({
    String? name,
    String? dosage,
    String? note,
    List<MedicationSchedule>? schedules,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      note: note ?? this.note,
      schedules: schedules ?? this.schedules,
    );
  }

  /// 🕒 Retourne l'heure de la première prise du médicament
  DateTime? getFirstTime() {
    try {
      if (schedules.isEmpty) return null;
      final parsedTimes = schedules
          .map((s) => DateFormat("HH:mm").parse(s.time))
          .toList()
        ..sort((a, b) => a.compareTo(b));
      final now = DateTime.now();
      final first = parsedTimes.first;
      return DateTime(now.year, now.month, now.day, first.hour, first.minute);
    } catch (_) {
      return null;
    }
  }
}

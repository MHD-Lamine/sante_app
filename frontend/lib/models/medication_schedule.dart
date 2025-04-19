import 'package:intl/intl.dart';

class MedicationSchedule {
  final int id;
  final String time; // Format "HH:mm"
  final bool taken;
  final String? note;

  MedicationSchedule({
    required this.id,
    required this.time,
    required this.taken,
    this.note,
  });

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) {
    return MedicationSchedule(
      id: json['id'],
      time: json['time'],
      taken: json['taken'],
      note: json['note'],
    );
  }

  MedicationSchedule copyWith({bool? taken}) {
    return MedicationSchedule(
      id: id,
      time: time,
      taken: taken ?? this.taken,
      note: note,
    );
  }

  /// 🔄 Afficher uniquement les prises entre [time - 30min] et [time + 2h]
  bool isVisibleNow() {
    try {
      final now = DateTime.now();
      final today = DateFormat('HH:mm').parse(time);
      final scheduledTime = DateTime(now.year, now.month, now.day, today.hour, today.minute);

      final windowStart = scheduledTime.subtract(const Duration(minutes: 30));
      final windowEnd = scheduledTime.add(const Duration(hours: 2));

      return now.isAfter(windowStart) && now.isBefore(windowEnd);
    } catch (e) {
      return true; // En cas d’erreur de parsing, on affiche par défaut
    }
  }
}

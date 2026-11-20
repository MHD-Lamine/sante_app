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

  /// Fenêtre d'affichage d'une prise : de [heure - 30 min] à [heure + 2h30]
  /// (ex : prise de 8h00 visible de 7h30 à 10h30)
  static const showBefore = Duration(minutes: 30);
  static const showAfter = Duration(hours: 2, minutes: 30);

  /// 🕒 Heure de la prise aujourd'hui (null si le format est invalide)
  DateTime? scheduledToday() {
    try {
      final now = DateTime.now();
      final parsed = DateFormat('HH:mm').parse(time);
      return DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
    } catch (_) {
      return null;
    }
  }

  /// 🔄 La prise est-elle dans sa fenêtre d'affichage ?
  bool isVisibleNow() {
    final scheduledTime = scheduledToday();
    if (scheduledTime == null) return false;
    final now = DateTime.now();
    return now.isAfter(scheduledTime.subtract(showBefore)) &&
        now.isBefore(scheduledTime.add(showAfter));
  }
}

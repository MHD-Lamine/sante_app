class MedicationSchedule {
  final int id;
  final String time; // au format "HH:mm"
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
}

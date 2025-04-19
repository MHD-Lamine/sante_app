class Measure {
  final double? glycemia;
  final double? systolic;
  final double? diastolic;
  final double? temperature;
  final DateTime date;

  Measure({
    this.glycemia,
    this.systolic,
    this.diastolic,
    this.temperature,
    required this.date,
  });

  Map<String, dynamic> toJson(int userId) {
    return {
      "user_id": userId,
      "glycemia": glycemia,
      "systolic": systolic,
      "diastolic": diastolic,
      "temperature": temperature,
      "date": date.toIso8601String(),
    };
  }
}

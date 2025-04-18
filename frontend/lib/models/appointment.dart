class Appointment {
  final int id;
  final String title;
  final String location;
  final String doctor;
  final DateTime dateTime;
  final String notes;

  Appointment({
    required this.id,
    required this.title,
    required this.location,
    required this.doctor,
    required this.dateTime,
    required this.notes,
  });
///
  /// Factory constructor to create an Appointment instance from JSON data.
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      doctor: json['doctor'],
      dateTime: DateTime.parse(json['date_time']),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'doctor': doctor,
      'date_time': dateTime.toIso8601String(),
      'notes': notes,
    };
  }
}

class HealthTip {
  final int id;
  final String content;
  final String type;
  final DateTime createdAt;

  HealthTip({
    required this.id,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  /// Factory constructor pour créer un objet HealthTip depuis un JSON
  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'],
      content: json['content'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class HealthTip {
  final int? id; // null quand le conseil vient des règles intégrées du backend
  final String content;
  final String type;
  final String? reason; // ex : "Votre dernière glycémie est élevée"

  HealthTip({
    this.id,
    required this.content,
    required this.type,
    this.reason,
  });

  /// Factory constructor pour créer un objet HealthTip depuis un JSON
  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'],
      content: json['content'],
      type: json['type'] ?? 'général',
      reason: json['reason'],
    );
  }
}

class HealthLog {
  final String? id;
  final String userId;
  final String logType;
  final int painLevel;
  final String bleedingLevel;
  final String mood;
  final String notes;
  final String logDate;
  final bool synced; // for offline mode

  HealthLog({
    this.id,
    required this.userId,
    required this.logType,
    required this.painLevel,
    required this.bleedingLevel,
    required this.mood,
    required this.notes,
    required this.logDate,
    this.synced = true,
  });

  factory HealthLog.fromJson(Map<String, dynamic> json) {
    return HealthLog(
      id: json['id'],
      userId: json['user_id'] ?? '',
      logType: json['log_type'] ?? 'health_check',
      painLevel: json['pain_level'] ?? 0,
      bleedingLevel: json['bleeding_level'] ?? 'light',
      mood: json['mood'] ?? '',
      notes: json['notes'] ?? '',
      logDate: json['log_date'] ?? '',
      synced: json['synced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'log_type': logType,
      'pain_level': painLevel,
      'bleeding_level': bleedingLevel,
      'mood': mood,
      'notes': notes,
      'log_date': logDate,
      'synced': synced,
    };
  }
}

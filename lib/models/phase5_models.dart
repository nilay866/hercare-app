import 'package:intl/intl.dart';

/// Health metric model
class HealthMetric {
  final String id;
  final String userId;
  final String metricType; // blood_pressure, weight, glucose, heart_rate, etc.
  final double value;
  final double? systolicValue; // For blood pressure
  final double? diastolicValue; // For blood pressure
  final String unit;
  final String? notes;
  final bool isAbnormal;
  final DateTime recordedAt;
  final DateTime createdAt;

  HealthMetric({
    required this.id,
    required this.userId,
    required this.metricType,
    required this.value,
    this.systolicValue,
    this.diastolicValue,
    required this.unit,
    this.notes,
    this.isAbnormal = false,
    required this.recordedAt,
    required this.createdAt,
  });

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      metricType: json['metric_type'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      systolicValue: json['systolic_value']?.toDouble(),
      diastolicValue: json['diastolic_value']?.toDouble(),
      unit: json['unit'] ?? '',
      notes: json['notes'],
      isAbnormal: json['is_abnormal'] ?? false,
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'metric_type': metricType,
        'value': value,
        'systolic_value': systolicValue,
        'diastolic_value': diastolicValue,
        'unit': unit,
        'notes': notes,
        'is_abnormal': isAbnormal,
        'recorded_at': recordedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  HealthMetric copyWith({
    String? id,
    String? userId,
    String? metricType,
    double? value,
    double? systolicValue,
    double? diastolicValue,
    String? unit,
    String? notes,
    bool? isAbnormal,
    DateTime? recordedAt,
    DateTime? createdAt,
  }) {
    return HealthMetric(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      metricType: metricType ?? this.metricType,
      value: value ?? this.value,
      systolicValue: systolicValue ?? this.systolicValue,
      diastolicValue: diastolicValue ?? this.diastolicValue,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      isAbnormal: isAbnormal ?? this.isAbnormal,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedValue => '$value $unit';
  String get formattedDate => DateFormat('MMM dd, yyyy').format(recordedAt);
  String get formattedTime => DateFormat('hh:mm a').format(recordedAt);
  bool get isBloodPressure => metricType == 'blood_pressure';
}

/// Health insight model (AI-generated)
class HealthInsight {
  final String id;
  final String userId;
  final String insightType; // medication_reminder, health_alert, wellness_tip, etc.
  final String title;
  final String description;
  final String? recommendation;
  final String priority; // low, medium, high, critical
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  HealthInsight({
    required this.id,
    required this.userId,
    required this.insightType,
    required this.title,
    required this.description,
    this.recommendation,
    this.priority = 'medium',
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  factory HealthInsight.fromJson(Map<String, dynamic> json) {
    return HealthInsight(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      insightType: json['insight_type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      recommendation: json['recommendation'],
      priority: json['priority'] ?? 'medium',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'insight_type': insightType,
        'title': title,
        'description': description,
        'recommendation': recommendation,
        'priority': priority,
        'is_read': isRead,
        'read_at': readAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  HealthInsight copyWith({
    String? id,
    String? userId,
    String? insightType,
    String? title,
    String? description,
    String? recommendation,
    String? priority,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return HealthInsight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      insightType: insightType ?? this.insightType,
      title: title ?? this.title,
      description: description ?? this.description,
      recommendation: recommendation ?? this.recommendation,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isCritical => priority == 'critical';
  bool get isHigh => priority == 'high';
  String get formattedDate => DateFormat('MMM dd, yyyy').format(createdAt);
}

/// Health report model
class HealthReport {
  final String id;
  final String userId;
  final String reportType; // monthly, quarterly, annual
  final DateTime periodStart;
  final DateTime periodEnd;
  final String summary;
  final List<String> keyFindings;
  final List<String> recommendations;
  final Map<String, dynamic>? metricsData;
  final int? metricsRecorded;
  final int? abnormalReadings;
  final int? healthAlerts;
  final bool? sharedWithDoctor;
  final DateTime generatedAt;

  HealthReport({
    required this.id,
    required this.userId,
    required this.reportType,
    required this.periodStart,
    required this.periodEnd,
    required this.summary,
    required this.keyFindings,
    required this.recommendations,
    this.metricsData,
    this.metricsRecorded,
    this.abnormalReadings,
    this.healthAlerts,
    this.sharedWithDoctor,
    required this.generatedAt,
  });

  factory HealthReport.fromJson(Map<String, dynamic> json) {
    return HealthReport(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      reportType: json['report_type'] ?? '',
      periodStart: json['period_start'] != null
          ? DateTime.parse(json['period_start'])
          : DateTime.now(),
      periodEnd: json['period_end'] != null
          ? DateTime.parse(json['period_end'])
          : DateTime.now(),
      summary: json['summary'] ?? '',
      keyFindings: json['key_findings'] != null
          ? List<String>.from(json['key_findings'])
          : [],
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'])
          : [],
      metricsData: json['metrics_data'],
      metricsRecorded: json['metrics_recorded'],
      abnormalReadings: json['abnormal_readings'],
      healthAlerts: json['health_alerts'],
      sharedWithDoctor: json['shared_with_doctor'],
      generatedAt: json['generated_at'] != null
          ? DateTime.parse(json['generated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'report_type': reportType,
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
        'summary': summary,
        'key_findings': keyFindings,
        'recommendations': recommendations,
        'metrics_data': metricsData,
        'metrics_recorded': metricsRecorded,
        'abnormal_readings': abnormalReadings,
        'health_alerts': healthAlerts,
        'shared_with_doctor': sharedWithDoctor,
        'generated_at': generatedAt.toIso8601String(),
      };

  HealthReport copyWith({
    String? id,
    String? userId,
    String? reportType,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? summary,
    List<String>? keyFindings,
    List<String>? recommendations,
    Map<String, dynamic>? metricsData,
    int? metricsRecorded,
    int? abnormalReadings,
    int? healthAlerts,
    bool? sharedWithDoctor,
    DateTime? generatedAt,
  }) {
    return HealthReport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reportType: reportType ?? this.reportType,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      summary: summary ?? this.summary,
      keyFindings: keyFindings ?? this.keyFindings,
      recommendations: recommendations ?? this.recommendations,
      metricsData: metricsData ?? this.metricsData,
      metricsRecorded: metricsRecorded ?? this.metricsRecorded,
      abnormalReadings: abnormalReadings ?? this.abnormalReadings,
      healthAlerts: healthAlerts ?? this.healthAlerts,
      sharedWithDoctor: sharedWithDoctor ?? this.sharedWithDoctor,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  String get formattedPeriod =>
      '${DateFormat('MMM dd').format(periodStart)} - ${DateFormat('MMM dd, yyyy').format(periodEnd)}';
  bool get isMonthly => reportType == 'monthly';
  bool get isQuarterly => reportType == 'quarterly';
  bool get isAnnual => reportType == 'annual';
}

/// Health dashboard data
class HealthDashboard {
  final int overallScore;
  final String trend; // improving, stable, declining
  final DateTime? lastCheckup;
  final DateTime? nextCheckup;
  final Map<String, dynamic> vitalSigns;
  final List<HealthInsight> recentInsights;
  final int upcomingAppointments;
  final int prescriptionsToRefill;
  final int healthAlerts;
  final int metricsTracked;
  final int healthRecords;
  final int appointmentsThisMonth;

  HealthDashboard({
    required this.overallScore,
    required this.trend,
    this.lastCheckup,
    this.nextCheckup,
    required this.vitalSigns,
    required this.recentInsights,
    required this.upcomingAppointments,
    required this.prescriptionsToRefill,
    required this.healthAlerts,
    required this.metricsTracked,
    required this.healthRecords,
    required this.appointmentsThisMonth,
  });

  factory HealthDashboard.fromJson(Map<String, dynamic> json) {
    return HealthDashboard(
      overallScore: json['overall_score'] ?? 0,
      trend: json['trend'] ?? 'stable',
      lastCheckup: json['last_checkup'] != null
          ? DateTime.parse(json['last_checkup'])
          : null,
      nextCheckup: json['next_checkup'] != null
          ? DateTime.parse(json['next_checkup'])
          : null,
      vitalSigns: json['vital_signs'] ?? {},
      recentInsights: json['recent_insights'] != null
          ? (json['recent_insights'] as List)
              .map((i) => HealthInsight.fromJson(i))
              .toList()
          : [],
      upcomingAppointments: json['upcoming_appointments'] ?? 0,
      prescriptionsToRefill: json['prescriptions_to_refill'] ?? 0,
      healthAlerts: json['health_alerts'] ?? 0,
      metricsTracked: json['metrics_tracked'] ?? 0,
      healthRecords: json['health_records'] ?? 0,
      appointmentsThisMonth: json['appointments_this_month'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'overall_score': overallScore,
        'trend': trend,
        'last_checkup': lastCheckup?.toIso8601String(),
        'next_checkup': nextCheckup?.toIso8601String(),
        'vital_signs': vitalSigns,
        'recent_insights': recentInsights.map((i) => i.toJson()).toList(),
        'upcoming_appointments': upcomingAppointments,
        'prescriptions_to_refill': prescriptionsToRefill,
        'health_alerts': healthAlerts,
        'metrics_tracked': metricsTracked,
        'health_records': healthRecords,
        'appointments_this_month': appointmentsThisMonth,
      };

  bool get isHealthy => overallScore >= 70;
  bool get isTrending => trend == 'improving' || trend == 'stable';
}

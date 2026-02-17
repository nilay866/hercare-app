import 'package:flutter/foundation.dart';
import '../services/analytics_service.dart';
import '../models/phase5_models.dart';

/// Provider for health analytics
class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _service;

  // Health Metrics State
  List<HealthMetric> _healthMetrics = [];
  bool _isLoadingMetrics = false;
  String? _metricsError;

  // Health Insights State
  List<HealthInsight> _healthInsights = [];
  bool _isLoadingInsights = false;
  String? _insightsError;

  // Health Reports State
  List<HealthReport> _healthReports = [];
  HealthReport? _currentReport;
  bool _isLoadingReports = false;
  String? _reportsError;

  // Dashboard State
  HealthDashboard? _dashboard;
  bool _isLoadingDashboard = false;
  String? _dashboardError;

  // General State
  Map<String, dynamic>? _preferences;
  bool _isLoading = false;
  String? _error;

  // Getters - Metrics
  List<HealthMetric> get healthMetrics => _healthMetrics;
  bool get isLoadingMetrics => _isLoadingMetrics;
  String? get metricsError => _metricsError;

  // Getters - Insights
  List<HealthInsight> get healthInsights => _healthInsights;
  bool get isLoadingInsights => _isLoadingInsights;
  String? get insightsError => _insightsError;

  // Getters - Reports
  List<HealthReport> get healthReports => _healthReports;
  HealthReport? get currentReport => _currentReport;
  bool get isLoadingReports => _isLoadingReports;
  String? get reportsError => _reportsError;

  // Getters - Dashboard
  HealthDashboard? get dashboard => _dashboard;
  bool get isLoadingDashboard => _isLoadingDashboard;
  String? get dashboardError => _dashboardError;

  // Getters - General
  Map<String, dynamic>? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  List<HealthInsight> get unreadInsights =>
      _healthInsights.where((i) => !i.isRead).toList();

  List<HealthInsight> get criticalInsights =>
      _healthInsights.where((i) => i.isCritical).toList();

  List<HealthInsight> get highPriorityInsights =>
      _healthInsights.where((i) => i.isHigh).toList();

  int get unreadCount => unreadInsights.length;

  AnalyticsProvider(this._service);

  // ==================== Health Metrics ====================

  /// Record a new health metric
  Future<void> recordHealthMetric({
    required String metricType,
    required double value,
    double? systolicValue,
    double? diastolicValue,
    required String unit,
    String? notes,
  }) async {
    _isLoadingMetrics = true;
    _metricsError = null;
    notifyListeners();

    try {
      final metric = await _service.recordHealthMetric(
        metricType: metricType,
        value: value,
        systolicValue: systolicValue,
        diastolicValue: diastolicValue,
        unit: unit,
        notes: notes,
      );

      _healthMetrics.add(metric);
      _isLoadingMetrics = false;
      notifyListeners();
    } catch (e) {
      _metricsError = e.toString();
      _isLoadingMetrics = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load health metrics
  Future<void> loadHealthMetrics({
    String? metricType,
    int days = 30,
  }) async {
    _isLoadingMetrics = true;
    _metricsError = null;
    notifyListeners();

    try {
      _healthMetrics = await _service.getHealthMetrics(
        metricType: metricType,
        days: days,
      );
      _isLoadingMetrics = false;
      notifyListeners();
    } catch (e) {
      _metricsError = e.toString();
      _isLoadingMetrics = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Get metric history
  Future<Map<String, dynamic>> getMetricHistory(
    String metricType, {
    int days = 90,
  }) async {
    _isLoadingMetrics = true;
    _metricsError = null;
    notifyListeners();

    try {
      final history =
          await _service.getMetricHistory(metricType, days: days);
      _isLoadingMetrics = false;
      notifyListeners();
      return history;
    } catch (e) {
      _metricsError = e.toString();
      _isLoadingMetrics = false;
      notifyListeners();
      rethrow;
    }
  }

  // ==================== Health Insights ====================

  /// Load health insights
  Future<void> loadHealthInsights({
    String? priority,
    bool unreadOnly = false,
    int skip = 0,
    int limit = 20,
  }) async {
    _isLoadingInsights = true;
    _insightsError = null;
    notifyListeners();

    try {
      _healthInsights = await _service.getHealthInsights(
        priority: priority,
        unreadOnly: unreadOnly,
        skip: skip,
        limit: limit,
      );
      _isLoadingInsights = false;
      notifyListeners();
    } catch (e) {
      _insightsError = e.toString();
      _isLoadingInsights = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Mark insight as read
  Future<void> markInsightAsRead(String insightId) async {
    try {
      await _service.markInsightAsRead(insightId);

      final index = _healthInsights.indexWhere((i) => i.id == insightId);
      if (index != -1) {
        _healthInsights[index] = _healthInsights[index].copyWith(isRead: true);
      }

      notifyListeners();
    } catch (e) {
      _insightsError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Take action on insight
  Future<void> takeInsightAction(
    String insightId,
    String actionType,
  ) async {
    try {
      await _service.takeInsightAction(insightId, actionType);
      notifyListeners();
    } catch (e) {
      _insightsError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ==================== Health Reports ====================

  /// Generate a new health report
  Future<void> generateHealthReport({
    required String reportType,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    _isLoadingReports = true;
    _reportsError = null;
    notifyListeners();

    try {
      final report = await _service.generateHealthReport(
        reportType: reportType,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );

      _healthReports.add(report);
      _currentReport = report;
      _isLoadingReports = false;
      notifyListeners();
    } catch (e) {
      _reportsError = e.toString();
      _isLoadingReports = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load all health reports
  Future<void> loadHealthReports({
    String? reportType,
    int skip = 0,
    int limit = 10,
  }) async {
    _isLoadingReports = true;
    _reportsError = null;
    notifyListeners();

    try {
      _healthReports = await _service.getHealthReports(
        reportType: reportType,
        skip: skip,
        limit: limit,
      );
      _isLoadingReports = false;
      notifyListeners();
    } catch (e) {
      _reportsError = e.toString();
      _isLoadingReports = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load a specific health report
  Future<void> loadHealthReport(String reportId) async {
    _isLoadingReports = true;
    _reportsError = null;
    notifyListeners();

    try {
      _currentReport = await _service.getHealthReport(reportId);
      _isLoadingReports = false;
      notifyListeners();
    } catch (e) {
      _reportsError = e.toString();
      _isLoadingReports = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Share report with doctor
  Future<void> shareReportWithDoctor(
    String reportId,
    String doctorId,
  ) async {
    try {
      await _service.shareReportWithDoctor(reportId, doctorId);

      final index = _healthReports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _healthReports[index] =
            _healthReports[index].copyWith(sharedWithDoctor: true);
      }

      notifyListeners();
    } catch (e) {
      _reportsError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ==================== Health Dashboard ====================

  /// Load health dashboard
  Future<void> loadDashboard() async {
    _isLoadingDashboard = true;
    _dashboardError = null;
    notifyListeners();

    try {
      _dashboard = await _service.getHealthDashboard();
      _isLoadingDashboard = false;
      notifyListeners();
    } catch (e) {
      _dashboardError = e.toString();
      _isLoadingDashboard = false;
      notifyListeners();
      rethrow;
    }
  }

  // ==================== User Preferences ====================

  /// Load preferences
  Future<void> loadPreferences() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _preferences = await _service.getPreferences();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Update preferences
  Future<void> updatePreferences({
    bool? notifyHealthAlerts,
    bool? notifyInsights,
    bool? notifyAppointments,
    bool? notifyPrescriptions,
    bool? dailyHealthReminder,
    String? reminderTime,
    bool? shareDataForResearch,
    String? privacyLevel,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _preferences = await _service.updatePreferences(
        notifyHealthAlerts: notifyHealthAlerts,
        notifyInsights: notifyInsights,
        notifyAppointments: notifyAppointments,
        notifyPrescriptions: notifyPrescriptions,
        dailyHealthReminder: dailyHealthReminder,
        reminderTime: reminderTime,
        shareDataForResearch: shareDataForResearch,
        privacyLevel: privacyLevel,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ==================== Utility Methods ====================

  /// Clear current report
  void clearCurrentReport() {
    _currentReport = null;
    notifyListeners();
  }

  /// Clear all errors
  void clearErrors() {
    _error = null;
    _metricsError = null;
    _insightsError = null;
    _reportsError = null;
    _dashboardError = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadHealthMetrics(),
      loadHealthInsights(),
      loadHealthReports(),
      loadDashboard(),
    ]);
  }
}

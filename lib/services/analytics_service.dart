import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import '../services/token_storage.dart';
import '../models/phase5_models.dart';

/// Service for health analytics and insights
class AnalyticsService {
  final String baseUrl;
  final http.Client httpClient;

  AnalyticsService({
    this.baseUrl = '${ApiService.baseUrl}/api/v1',
    http.Client? httpClient,
  })  : httpClient = httpClient ?? http.Client();

  Future<String?> _getToken() async {
    return await TokenStorage.read('token');
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    final headers = _getHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ==================== Health Metrics ====================

  /// Record a health metric
  Future<HealthMetric> recordHealthMetric({
    required String metricType,
    required double value,
    double? systolicValue,
    double? diastolicValue,
    required String unit,
    String? notes,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = {
        'metric_type': metricType,
        'value': value,
        'systolic_value': systolicValue,
        'diastolic_value': diastolicValue,
        'unit': unit,
        'notes': notes,
      };

      final response = await httpClient.post(
        Uri.parse('$baseUrl/analytics/health-metrics'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return HealthMetric.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to record metric: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error recording metric: $e');
    }
  }

  /// Get health metrics
  Future<List<HealthMetric>> getHealthMetrics({
    String? metricType,
    int days = 30,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      String url = '$baseUrl/analytics/health-metrics?days=$days';
      if (metricType != null) {
        url += '&metric_type=$metricType';
      }

      final response = await httpClient.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final metrics = (data['metrics'] as List)
            .map((m) => HealthMetric.fromJson(m))
            .toList();
        return metrics;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting metrics: $e');
    }
  }

  /// Get metric history
  Future<Map<String, dynamic>> getMetricHistory(
    String metricType, {
    int days = 90,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.get(
        Uri.parse('$baseUrl/analytics/health-metrics/$metricType?days=$days'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get metric history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting metric history: $e');
    }
  }

  // ==================== Health Insights ====================

  /// Get health insights
  Future<List<HealthInsight>> getHealthInsights({
    String? priority,
    bool unreadOnly = false,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      String url = '$baseUrl/analytics/insights?skip=$skip&limit=$limit';
      if (priority != null) {
        url += '&priority=$priority';
      }
      if (unreadOnly) {
        url += '&unread_only=true';
      }

      final response = await httpClient.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final insights = (data['insights'] as List)
            .map((i) => HealthInsight.fromJson(i))
            .toList();
        return insights;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get insights: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting insights: $e');
    }
  }

  /// Mark insight as read
  Future<void> markInsightAsRead(String insightId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.put(
        Uri.parse('$baseUrl/analytics/insights/$insightId/read'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('Unauthorized');
        } else {
          throw Exception('Failed to mark insight as read: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error marking insight as read: $e');
    }
  }

  /// Take action on insight
  Future<void> takeInsightAction(
    String insightId,
    String actionType,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final body = {'action_type': actionType};

      final response = await httpClient.post(
        Uri.parse('$baseUrl/analytics/insights/$insightId/action'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('Unauthorized');
        } else {
          throw Exception('Failed to take action: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error taking action: $e');
    }
  }

  // ==================== Health Reports ====================

  /// Generate health report
  Future<HealthReport> generateHealthReport({
    required String reportType,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = {
        'report_type': reportType,
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
      };

      final response = await httpClient.post(
        Uri.parse('$baseUrl/analytics/reports'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return HealthReport.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to generate report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating report: $e');
    }
  }

  /// Get all health reports
  Future<List<HealthReport>> getHealthReports({
    String? reportType,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      String url = '$baseUrl/analytics/reports?skip=$skip&limit=$limit';
      if (reportType != null) {
        url += '&report_type=$reportType';
      }

      final response = await httpClient.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reports = (data['reports'] as List)
            .map((r) => HealthReport.fromJson(r))
            .toList();
        return reports;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting reports: $e');
    }
  }

  /// Get a specific report
  Future<HealthReport> getHealthReport(String reportId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.get(
        Uri.parse('$baseUrl/analytics/reports/$reportId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return HealthReport.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        throw Exception('Report not found');
      } else {
        throw Exception('Failed to get report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting report: $e');
    }
  }

  /// Share report with doctor
  Future<void> shareReportWithDoctor(
    String reportId,
    String doctorId,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final body = {'doctor_id': doctorId};

      final response = await httpClient.post(
        Uri.parse('$baseUrl/analytics/reports/$reportId/share'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('Unauthorized');
        } else {
          throw Exception('Failed to share report: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error sharing report: $e');
    }
  }

  // ==================== Health Dashboard ====================

  /// Get health dashboard
  Future<HealthDashboard> getHealthDashboard() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.get(
        Uri.parse('$baseUrl/analytics/dashboard'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return HealthDashboard.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting dashboard: $e');
    }
  }

  // ==================== User Preferences ====================

  /// Get analytics preferences
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.get(
        Uri.parse('$baseUrl/analytics/preferences'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get preferences: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting preferences: $e');
    }
  }

  /// Update analytics preferences
  Future<Map<String, dynamic>> updatePreferences({
    bool? notifyHealthAlerts,
    bool? notifyInsights,
    bool? notifyAppointments,
    bool? notifyPrescriptions,
    bool? dailyHealthReminder,
    String? reminderTime,
    bool? shareDataForResearch,
    String? privacyLevel,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = {
        'notify_health_alerts': notifyHealthAlerts,
        'notify_insights': notifyInsights,
        'notify_appointments': notifyAppointments,
        'notify_prescriptions': notifyPrescriptions,
        'daily_health_reminder': dailyHealthReminder,
        'reminder_time': reminderTime,
        'share_data_for_research': shareDataForResearch,
        'privacy_level': privacyLevel,
      };

      final response = await httpClient.put(
        Uri.parse('$baseUrl/analytics/preferences'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to update preferences: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating preferences: $e');
    }
  }

  // ==================== Doctor Analytics ====================

  /// Get doctor statistics (doctor only)
  Future<Map<String, dynamic>> getDoctorStatistics({
    int periodDays = 30,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.get(
        Uri.parse('$baseUrl/analytics/doctor/statistics?period_days=$periodDays'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get doctor statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting doctor statistics: $e');
    }
  }

  // ==================== Platform Analytics ====================

  /// Get platform statistics (admin only)
  Future<Map<String, dynamic>> getPlatformStatistics({
    int periodDays = 30,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.get(
        Uri.parse('$baseUrl/analytics/platform/statistics?period_days=$periodDays'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get platform statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting platform statistics: $e');
    }
  }
}

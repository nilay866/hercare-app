import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/phase2_models.dart';

class NotificationService {
  static const String baseUrl = 'http://localhost:8000';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<List<AppNotification>> getNotifications({
    bool? unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      final token = await _getToken();
      String url = '$baseUrl/notifications?limit=$limit';
      if (unreadOnly ?? false) {
        url += '&unread_only=true';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<AppNotification> notifications = (data['notifications'] as List)
            .map((n) => AppNotification.fromJson(n))
            .toList();
        return notifications;
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error getting notifications: $e');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['unread_count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  Future<AppNotification> getNotification(String notificationId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AppNotification.fromJson(data);
      } else {
        throw Exception('Failed to load notification');
      }
    } catch (e) {
      print('Error getting notification: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      print('Error marking as read: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all as read');
      }
    } catch (e) {
      print('Error marking all as read: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  Future<void> sendNotification({
    required String title,
    required String message,
    String notificationType = 'info',
    String channel = 'in_app',
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'message': message,
          'notification_type': notificationType,
          'channel': channel,
          'action_url': actionUrl,
          'metadata': metadata,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send notification');
      }
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  Future<void> updateNotificationPreferences({
    required bool emailEnabled,
    required bool smsEnabled,
    required bool pushEnabled,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/preferences'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email_enabled': emailEnabled,
          'sms_enabled': smsEnabled,
          'push_enabled': pushEnabled,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update preferences');
      }
    } catch (e) {
      print('Error updating preferences: $e');
      rethrow;
    }
  }
}

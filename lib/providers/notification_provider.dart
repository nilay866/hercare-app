import 'package:flutter/material.dart';
import '../models/phase2_models.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  Map<String, bool> _notificationPreferences = {};

  // Getters
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, bool> get notificationPreferences => _notificationPreferences;

  // Get unread notifications
  List<AppNotification> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Get notifications by type
  List<AppNotification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Load notifications
  Future<void> loadNotifications({int limit = 20, int offset = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _service.getNotifications(
        limit: limit,
      );
      await getUnreadCount();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get unread count
  Future<void> getUnreadCount() async {
    try {
      _unreadCount = await _service.getUnreadCount();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Mark as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      final success = true;
      
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index >= 0) {
          final notif = _notifications[index];
          _notifications[index] = notif.copyWith(isRead: true);
        }
        
        if (_unreadCount > 0) {
          _unreadCount--;
        }
        
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Mark all as read
  Future<bool> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      final success = true;
      
      if (success) {
        for (int i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
        _unreadCount = 0;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteNotification(notificationId);
      final success = true;
      
      if (success) {
        _notifications.removeWhere((n) => n.id == notificationId);
        _error = null;
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update notification preferences
  Future<bool> updateNotificationPreferences(
    Map<String, bool> preferences,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateNotificationPreferences(
        emailEnabled: preferences['email'] ?? false,
        smsEnabled: preferences['sms'] ?? false,
        pushEnabled: preferences['push'] ?? false,
      );
      final updated = true;
      
      if (updated) {
        _notificationPreferences = preferences;
        _error = null;
      }
      
      return updated;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle notification preference
  Future<bool> togglePreference(String channel) async {
    final currentValue = _notificationPreferences[channel] ?? true;
    final newValue = !currentValue;
    
    final newPreferences = Map<String, bool>.from(_notificationPreferences);
    newPreferences[channel] = newValue;
    
    return updateNotificationPreferences(newPreferences);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

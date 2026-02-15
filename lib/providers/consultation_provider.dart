import 'package:flutter/foundation.dart';
import 'telemedicine_service.dart';
import '../models/phase4_models.dart';

/// Provider for managing consultations
class ConsultationProvider extends ChangeNotifier {
  final TelemedicineService _service;

  // State
  List<VideoConsultation> _consultations = [];
  VideoConsultation? _currentConsultation;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<VideoConsultation> get consultations => _consultations;
  VideoConsultation? get currentConsultation => _currentConsultation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  List<VideoConsultation> get upcomingConsultations =>
      _consultations.where((c) => c.isScheduled).toList();

  List<VideoConsultation> get ongoingConsultations =>
      _consultations.where((c) => c.isOngoing).toList();

  List<VideoConsultation> get completedConsultations =>
      _consultations.where((c) => c.isCompleted).toList();

  int get unratedConsultationCount =>
      _consultations.where((c) => c.isCompleted && c.rating == null).length;

  ConsultationProvider(this._service);

  // ==================== Consultation Operations ====================

  /// Schedule a new consultation
  Future<void> scheduleConsultation({
    required String doctorId,
    required String title,
    String? description,
    required DateTime scheduledAt,
    String consultationType = 'video',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final consultation = await _service.scheduleConsultation(
        doctorId: doctorId,
        title: title,
        description: description,
        scheduledAt: scheduledAt,
        consultationType: consultationType,
      );

      _consultations.add(consultation);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load all consultations
  Future<void> loadConsultations({
    String? status,
    int skip = 0,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _consultations = await _service.getConsultations(
        status: status,
        skip: skip,
        limit: limit,
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

  /// Load a specific consultation
  Future<void> loadConsultation(String consultationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentConsultation = await _service.getConsultation(consultationId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Start a consultation
  Future<void> startConsultation(String consultationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.startConsultation(consultationId);
      _currentConsultation = updated;

      final index = _consultations.indexWhere((c) => c.id == consultationId);
      if (index != -1) {
        _consultations[index] = updated;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// End a consultation
  Future<void> endConsultation(
    String consultationId, {
    String? followUpAction,
    DateTime? followUpDate,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.endConsultation(
        consultationId,
        followUpAction: followUpAction,
        followUpDate: followUpDate,
        notes: notes,
      );

      _currentConsultation = updated;

      final index = _consultations.indexWhere((c) => c.id == consultationId);
      if (index != -1) {
        _consultations[index] = updated;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Cancel a consultation
  Future<void> cancelConsultation(String consultationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.cancelConsultation(consultationId);

      final index = _consultations.indexWhere((c) => c.id == consultationId);
      if (index != -1) {
        _consultations[index] = updated;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Rate a consultation
  Future<void> rateConsultation(
    String consultationId,
    double rating,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.rateConsultation(consultationId, rating);
      _currentConsultation = updated;

      final index = _consultations.indexWhere((c) => c.id == consultationId);
      if (index != -1) {
        _consultations[index] = updated;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Clear current consultation
  void clearCurrentConsultation() {
    _currentConsultation = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Provider for managing messaging
class MessagingProvider extends ChangeNotifier {
  final TelemedicineService _service;

  // State
  List<Conversation> _conversations = [];
  List<Message> _currentConsultationMessages = [];
  List<DirectMessage> _currentConversationMessages = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  // Getters
  List<Conversation> get conversations => _conversations;
  List<Message> get currentConsultationMessages => _currentConsultationMessages;
  List<DirectMessage> get currentConversationMessages =>
      _currentConversationMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Computed properties
  int get unreadConversationsCount =>
      _conversations.where((c) => c.hasUnread).length;

  MessagingProvider(this._service);

  // ==================== Consultation Messages ====================

  /// Send a message in consultation
  Future<void> sendConsultationMessage(
    String consultationId, {
    required String content,
    String messageType = 'text',
    String? fileUrl,
    String? fileName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final message = await _service.sendMessage(
        consultationId,
        content: content,
        messageType: messageType,
        fileUrl: fileUrl,
        fileName: fileName,
      );

      _currentConsultationMessages.add(message);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load consultation messages
  Future<void> loadConsultationMessages(
    String consultationId, {
    int skip = 0,
    int limit = 50,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentConsultationMessages = await _service.getConsultationMessages(
        consultationId,
        skip: skip,
        limit: limit,
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

  /// Clear consultation messages
  void clearConsultationMessages() {
    _currentConsultationMessages = [];
    notifyListeners();
  }

  // ==================== Direct Messages & Conversations ====================

  /// Send a direct message
  Future<void> sendDirectMessage({
    required String recipientId,
    required String content,
    String messageType = 'text',
    String? fileUrl,
    String? fileName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.sendDirectMessage(
        recipientId: recipientId,
        content: content,
        messageType: messageType,
        fileUrl: fileUrl,
        fileName: fileName,
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

  /// Load all conversations
  Future<void> loadConversations({
    int skip = 0,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _service.getConversations(
        skip: skip,
        limit: limit,
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

  /// Load conversation messages
  Future<void> loadConversationMessages(
    String conversationId, {
    int skip = 0,
    int limit = 50,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentConversationMessages = await _service.getConversationMessages(
        conversationId,
        skip: skip,
        limit: limit,
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

  /// Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _service.markConversationAsRead(conversationId);

      final index =
          _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Archive a conversation
  Future<void> archiveConversation(String conversationId) async {
    try {
      await _service.archiveConversation(conversationId);

      _conversations.removeWhere((c) => c.id == conversationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _service.deleteConversation(conversationId);

      _conversations.removeWhere((c) => c.id == conversationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Load unread conversation count
  Future<void> loadUnreadConversationCount() async {
    try {
      _unreadCount = await _service.getUnreadConversationCount();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clear conversation messages
  void clearConversationMessages() {
    _currentConversationMessages = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

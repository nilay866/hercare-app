import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import '../services/token_storage.dart';
import '../models/phase4_models.dart';

/// Service for telemedicine and messaging operations
class TelemedicineService {
  final String baseUrl;
  final http.Client httpClient;

  TelemedicineService({
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

  // ==================== Video Consultations ====================

  /// Schedule a video consultation
  Future<VideoConsultation> scheduleConsultation({
    required String doctorId,
    required String title,
    String? description,
    required DateTime scheduledAt,
    String consultationType = 'video',
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = {
        'doctor_id': doctorId,
        'title': title,
        'description': description,
        'scheduled_at': scheduledAt.toIso8601String(),
        'consultation_type': consultationType,
      };

      final response = await httpClient.post(
        Uri.parse('$baseUrl/telemedicine/consultations'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return VideoConsultation.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to schedule consultation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error scheduling consultation: $e');
    }
  }

  /// Get all consultations
  Future<List<VideoConsultation>> getConsultations({
    String? status,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      String url = '$baseUrl/telemedicine/consultations?skip=$skip&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await httpClient.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final consultations = (data['consultations'] as List)
            .map((c) => VideoConsultation.fromJson(c))
            .toList();
        return consultations;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get consultations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting consultations: $e');
    }
  }

  /// Get a specific consultation
  Future<VideoConsultation> getConsultation(String consultationId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.get(
        Uri.parse('$baseUrl/telemedicine/consultations/$consultationId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return VideoConsultation.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        throw Exception('Consultation not found');
      } else {
        throw Exception('Failed to get consultation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting consultation: $e');
    }
  }

  /// Start a consultation
  Future<VideoConsultation> startConsultation(String consultationId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.post(
        Uri.parse('$baseUrl/telemedicine/consultations/$consultationId/start'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return VideoConsultation.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to start consultation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting consultation: $e');
    }
  }

  /// End a consultation
  Future<VideoConsultation> endConsultation(
    String consultationId, {
    String? followUpAction,
    DateTime? followUpDate,
    String? notes,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = {
        'follow_up_action': followUpAction,
        'follow_up_date': followUpDate?.toIso8601String(),
        'notes': notes,
      };

      final response = await httpClient.post(
        Uri.parse('$baseUrl/telemedicine/consultations/$consultationId/end'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return VideoConsultation.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to end consultation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error ending consultation: $e');
    }
  }

  /// Cancel a consultation
  Future<VideoConsultation> cancelConsultation(String consultationId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.post(
        Uri.parse('$baseUrl/telemedicine/consultations/$consultationId/cancel'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return VideoConsultation.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to cancel consultation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error cancelling consultation: $e');
    }
  }

  /// Rate a consultation
  Future<VideoConsultation> rateConsultation(
    String consultationId,
    double rating,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final body = {'rating': rating};

      final response = await httpClient.post(
        Uri.parse('$baseUrl/telemedicine/consultations/$consultationId/rate'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return VideoConsultation.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to rate consultation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rating consultation: $e');
    }
  }

  // ==================== Messages ====================

  /// Send a message in consultation
  Future<Message> sendMessage(
    String consultationId, {
    required String content,
    String messageType = 'text',
    String? fileUrl,
    String? fileName,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = {
        'content': content,
        'message_type': messageType,
        'file_url': fileUrl,
        'file_name': fileName,
      };

      final response = await httpClient.post(
        Uri.parse('$baseUrl/telemedicine/consultations/$consultationId/messages'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return Message.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  /// Get messages for a consultation
  Future<List<Message>> getConsultationMessages(
    String consultationId, {
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.get(
        Uri.parse(
          '$baseUrl/telemedicine/consultations/$consultationId/messages?skip=$skip&limit=$limit',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final messages = (data['messages'] as List)
            .map((m) => Message.fromJson(m))
            .toList();
        return messages;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting messages: $e');
    }
  }

  // ==================== Direct Messages ====================

  /// Send a direct message
  Future<DirectMessage> sendDirectMessage({
    required String recipientId,
    required String content,
    String messageType = 'text',
    String? fileUrl,
    String? fileName,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = {
        'recipient_id': recipientId,
        'content': content,
        'message_type': messageType,
        'file_url': fileUrl,
        'file_name': fileName,
      };

      final response = await httpClient.post(
        Uri.parse('$baseUrl/telemedicine/direct-messages'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return DirectMessage.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to send direct message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending direct message: $e');
    }
  }

  // ==================== Conversations ====================

  /// Get all conversations
  Future<List<Conversation>> getConversations({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.get(
        Uri.parse('$baseUrl/telemedicine/conversations?skip=$skip&limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final conversations = (data['conversations'] as List)
            .map((c) => Conversation.fromJson(c))
            .toList();
        return conversations;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get conversations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting conversations: $e');
    }
  }

  /// Get messages in a conversation
  Future<List<DirectMessage>> getConversationMessages(
    String conversationId, {
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.get(
        Uri.parse(
          '$baseUrl/telemedicine/conversations/$conversationId/messages?skip=$skip&limit=$limit',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final messages = (data['messages'] as List)
            .map((m) => DirectMessage.fromJson(m))
            .toList();
        return messages;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get conversation messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting conversation messages: $e');
    }
  }

  /// Mark conversation as read
  Future<Conversation> markConversationAsRead(String conversationId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.post(
        Uri.parse('$baseUrl/telemedicine/conversations/$conversationId/read'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Conversation.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to mark conversation as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking conversation as read: $e');
    }
  }

  /// Archive a conversation
  Future<Conversation> archiveConversation(String conversationId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.post(
        Uri.parse('$baseUrl/telemedicine/conversations/$conversationId/archive'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Conversation.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to archive conversation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error archiving conversation: $e');
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/telemedicine/conversations/$conversationId'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to delete conversation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting conversation: $e');
    }
  }

  /// Get unread conversation count
  Future<int> getUnreadConversationCount() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await httpClient.get(
        Uri.parse('$baseUrl/telemedicine/conversations/unread-count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['unread_count'] ?? 0;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting unread count: $e');
    }
  }
}

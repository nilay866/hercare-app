import 'package:intl/intl.dart';

/// Video consultation model
class VideoConsultation {
  final String id;
  final String patientId;
  final String doctorId;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String consultationType; // "video", "audio"
  final String status; // "scheduled", "ongoing", "completed", "cancelled"
  final String? meetingToken;
  final String? recordingUrl;
  final List<String>? attachmentUrls;
  final String? followUpAction;
  final DateTime? followUpDate;
  final double? rating;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VideoConsultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.title,
    this.description,
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.consultationType = "video",
    this.status = "scheduled",
    this.meetingToken,
    this.recordingUrl,
    this.attachmentUrls,
    this.followUpAction,
    this.followUpDate,
    this.rating,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoConsultation.fromJson(Map<String, dynamic> json) {
    return VideoConsultation(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : DateTime.now(),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      consultationType: json['consultation_type'] ?? 'video',
      status: json['status'] ?? 'scheduled',
      meetingToken: json['meeting_token'],
      recordingUrl: json['recording_url'],
      attachmentUrls: json['attachment_urls'] != null
          ? List<String>.from(json['attachment_urls'])
          : null,
      followUpAction: json['follow_up_action'],
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'])
          : null,
      rating: json['rating']?.toDouble(),
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'doctor_id': doctorId,
        'title': title,
        'description': description,
        'scheduled_at': scheduledAt.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'consultation_type': consultationType,
        'status': status,
        'meeting_token': meetingToken,
        'recording_url': recordingUrl,
        'attachment_urls': attachmentUrls,
        'follow_up_action': followUpAction,
        'follow_up_date': followUpDate?.toIso8601String(),
        'rating': rating,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  VideoConsultation copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? title,
    String? description,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? endedAt,
    String? consultationType,
    String? status,
    String? meetingToken,
    String? recordingUrl,
    List<String>? attachmentUrls,
    String? followUpAction,
    DateTime? followUpDate,
    double? rating,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VideoConsultation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      consultationType: consultationType ?? this.consultationType,
      status: status ?? this.status,
      meetingToken: meetingToken ?? this.meetingToken,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      followUpAction: followUpAction ?? this.followUpAction,
      followUpDate: followUpDate ?? this.followUpDate,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isScheduled => status == 'scheduled';
  bool get isOngoing => status == 'ongoing';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get hasRecording => recordingUrl != null && recordingUrl!.isNotEmpty;
  String get formattedDate => DateFormat('MMM dd, yyyy').format(scheduledAt);
  String get formattedTime => DateFormat('hh:mm a').format(scheduledAt);
}

/// Message in consultation
class Message {
  final String id;
  final String consultationId;
  final String senderId;
  final String senderName;
  final String content;
  final String messageType; // "text", "image", "file"
  final String? fileUrl;
  final String? fileName;
  final bool isRead;
  final DateTime readAt;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.consultationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.messageType = "text",
    this.fileUrl,
    this.fileName,
    this.isRead = false,
    required this.readAt,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      consultationId: json['consultation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'] ?? '',
      content: json['content'] ?? '',
      messageType: json['message_type'] ?? 'text',
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'consultation_id': consultationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'content': content,
        'message_type': messageType,
        'file_url': fileUrl,
        'file_name': fileName,
        'is_read': isRead,
        'read_at': readAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  Message copyWith({
    String? id,
    String? consultationId,
    String? senderId,
    String? senderName,
    String? content,
    String? messageType,
    String? fileUrl,
    String? fileName,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      consultationId: consultationId ?? this.consultationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isText => messageType == 'text';
  bool get isImage => messageType == 'image';
  bool get isFile => messageType == 'file';
  String get formattedTime => DateFormat('hh:mm a').format(createdAt);
}

/// Direct message (outside of consultation)
class DirectMessage {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final String messageType; // "text", "image", "file"
  final String? fileUrl;
  final String? fileName;
  final bool isRead;
  final DateTime readAt;
  final DateTime createdAt;

  DirectMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    this.messageType = "text",
    this.fileUrl,
    this.fileName,
    this.isRead = false,
    required this.readAt,
    required this.createdAt,
  });

  factory DirectMessage.fromJson(Map<String, dynamic> json) {
    return DirectMessage(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      recipientId: json['recipient_id'] ?? '',
      content: json['content'] ?? '',
      messageType: json['message_type'] ?? 'text',
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'recipient_id': recipientId,
        'content': content,
        'message_type': messageType,
        'file_url': fileUrl,
        'file_name': fileName,
        'is_read': isRead,
        'read_at': readAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  DirectMessage copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? content,
    String? messageType,
    String? fileUrl,
    String? fileName,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return DirectMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedTime => DateFormat('hh:mm a').format(createdAt);
}

/// Conversation thread
class Conversation {
  final String id;
  final String userId;
  final String otherId;
  final String? otherName;
  final String? otherAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.userId,
    required this.otherId,
    this.otherName,
    this.otherAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      otherId: json['other_id'] ?? '',
      otherName: json['other_name'],
      otherAvatar: json['other_avatar'],
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
      isArchived: json['is_archived'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'other_id': otherId,
        'other_name': otherName,
        'other_avatar': otherAvatar,
        'last_message': lastMessage,
        'last_message_time': lastMessageTime.toIso8601String(),
        'unread_count': unreadCount,
        'is_archived': isArchived,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Conversation copyWith({
    String? id,
    String? userId,
    String? otherId,
    String? otherName,
    String? otherAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      otherId: otherId ?? this.otherId,
      otherName: otherName ?? this.otherName,
      otherAvatar: otherAvatar ?? this.otherAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasUnread => unreadCount > 0;
  String get formattedTime => DateFormat('hh:mm a').format(lastMessageTime);
}

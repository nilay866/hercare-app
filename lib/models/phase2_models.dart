// Appointment Model
class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final DateTime appointmentDate;
  final int durationMinutes;
  final String status; // scheduled, completed, cancelled, no_show
  final String appointmentType; // consultation, followup, checkup
  final String? notes;
  final String? cancellationReason;
  final String? reason;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.appointmentDate,
    this.durationMinutes = 30,
    this.status = 'scheduled',
    this.appointmentType = 'consultation',
    this.notes,
    this.cancellationReason,
    this.reason,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctorId: json['doctor_id'],
      doctorName: json['doctor_name'] ?? 'Doctor',
      patientId: json['patient_id'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      durationMinutes: json['duration_minutes'] ?? 30,
      status: json['status'] ?? 'scheduled',
      appointmentType: json['appointment_type'] ?? 'consultation',
      notes: json['notes'],
      cancellationReason: json['cancellation_reason'],
      reason: json['reason'],
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'appointment_date': appointmentDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'status': status,
      'appointment_type': appointmentType,
      'notes': notes,
      'cancellation_reason': cancellationReason,
      'reason': reason,
      'location': location,
    };
  }

  Appointment copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? patientId,
    DateTime? appointmentDate,
    int? durationMinutes,
    String? status,
    String? appointmentType,
    String? notes,
    String? cancellationReason,
    String? reason,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      patientId: patientId ?? this.patientId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      appointmentType: appointmentType ?? this.appointmentType,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      reason: reason ?? this.reason,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// File Model
class MedicalFile {
  final String id;
  final String userId;
  final String fileName;
  final String fileType; // pdf, image, document, etc.
  final int fileSize;
  final String? s3Url;
  final String resourceType; // medical_report, prescription, profile_photo
  final String? resourceId;
  final String uploadedBy;
  final bool isPublic;
  final List<String> sharedWith;
  final DateTime createdAt;
  final DateTime? expiresAt;

  DateTime get uploadedAt => createdAt;

  MedicalFile({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    this.s3Url,
    required this.resourceType,
    this.resourceId,
    required this.uploadedBy,
    this.isPublic = false,
    this.sharedWith = const [],
    required this.createdAt,
    this.expiresAt,
  });

  factory MedicalFile.fromJson(Map<String, dynamic> json) {
    return MedicalFile(
      id: json['id'],
      userId: json['user_id'],
      fileName: json['file_name'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      s3Url: json['s3_url'],
      resourceType: json['resource_type'],
      resourceId: json['resource_id'],
      uploadedBy: json['uploaded_by'],
      isPublic: json['is_public'] ?? false,
      sharedWith: (json['shared_with'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      's3_url': s3Url,
      'resource_type': resourceType,
      'resource_id': resourceId,
      'uploaded_by': uploadedBy,
      'is_public': isPublic,
      'shared_with': sharedWith,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  MedicalFile copyWith({
    String? id,
    String? userId,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? s3Url,
    String? resourceType,
    String? resourceId,
    String? uploadedBy,
    bool? isPublic,
    List<String>? sharedWith,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return MedicalFile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      s3Url: s3Url ?? this.s3Url,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      isPublic: isPublic ?? this.isPublic,
      sharedWith: sharedWith ?? this.sharedWith,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

// Notification Model
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String notificationType; // info, warning, error, success
  final String channel; // in_app, email, sms, push
  final bool isRead;
  final DateTime? readAt;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  String get type => notificationType;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.notificationType = 'info',
    this.channel = 'in_app',
    this.isRead = false,
    this.readAt,
    this.actionUrl,
    this.metadata,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      notificationType: json['notification_type'] ?? 'info',
      channel: json['channel'] ?? 'in_app',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      actionUrl: json['action_url'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'channel': channel,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'action_url': actionUrl,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? notificationType,
    String? channel,
    bool? isRead,
    DateTime? readAt,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      channel: channel ?? this.channel,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

import 'package:intl/intl.dart';

/// Phase 3 Data Models for Doctor and Prescription Features

class DoctorProfile {
  final String doctorId;
  final String name;
  final String email;
  final String phone;
  final String? hospitalId;
  final List<Specialization> specializations;
  final double averageRating;
  final int totalRatings;
  final int totalPatients;
  final int yearsExperience;
  final String bio;
  final String? profilePhotoUrl;

  DoctorProfile({
    required this.doctorId,
    required this.name,
    required this.email,
    required this.phone,
    this.hospitalId,
    required this.specializations,
    required this.averageRating,
    required this.totalRatings,
    required this.totalPatients,
    required this.yearsExperience,
    required this.bio,
    this.profilePhotoUrl,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      doctorId: json['doctor_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      hospitalId: json['hospital_id'],
      specializations: (json['specializations'] as List?)
          ?.map((s) => Specialization.fromJson(s))
          .toList() ?? [],
      averageRating: (json['average_rating'] ?? 4.5).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      totalPatients: json['total_patients'] ?? 0,
      yearsExperience: json['years_experience'] ?? 0,
      bio: json['bio'] ?? '',
      profilePhotoUrl: json['profile_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'name': name,
      'email': email,
      'phone': phone,
      'hospital_id': hospitalId,
      'specializations': specializations.map((s) => s.toJson()).toList(),
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'total_patients': totalPatients,
      'years_experience': yearsExperience,
      'bio': bio,
      'profile_photo_url': profilePhotoUrl,
    };
  }

  DoctorProfile copyWith({
    String? doctorId,
    String? name,
    String? email,
    String? phone,
    String? hospitalId,
    List<Specialization>? specializations,
    double? averageRating,
    int? totalRatings,
    int? totalPatients,
    int? yearsExperience,
    String? bio,
    String? profilePhotoUrl,
  }) {
    return DoctorProfile(
      doctorId: doctorId ?? this.doctorId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hospitalId: hospitalId ?? this.hospitalId,
      specializations: specializations ?? this.specializations,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      totalPatients: totalPatients ?? this.totalPatients,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}

class Specialization {
  final String specialtyId;
  final String specialty;
  final String licenseNumber;
  final String issuingCountry;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final bool verified;
  final DateTime? verificationDate;

  Specialization({
    required this.specialtyId,
    required this.specialty,
    required this.licenseNumber,
    required this.issuingCountry,
    required this.issueDate,
    this.expiryDate,
    required this.verified,
    this.verificationDate,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      specialtyId: json['specialty_id'] ?? '',
      specialty: json['specialty'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      issuingCountry: json['issuing_country'] ?? '',
      issueDate: DateTime.parse(json['issue_date'] ?? DateTime.now().toIso8601String()),
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      verified: json['verified'] ?? false,
      verificationDate: json['verification_date'] != null 
          ? DateTime.parse(json['verification_date']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialty_id': specialtyId,
      'specialty': specialty,
      'license_number': licenseNumber,
      'issuing_country': issuingCountry,
      'issue_date': issueDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'verified': verified,
      'verification_date': verificationDate?.toIso8601String(),
    };
  }
}

class Prescription {
  final String prescriptionId;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String medicationName;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String? instructions;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int refillsAllowed;
  final int refillsUsed;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Prescription({
    required this.prescriptionId,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    this.instructions,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.refillsAllowed,
    required this.refillsUsed,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      prescriptionId: json['prescription_id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      patientId: json['patient_id'] ?? '',
      patientName: json['patient_name'] ?? '',
      medicationName: json['medication_name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      durationDays: json['duration_days'] ?? 0,
      instructions: json['instructions'],
      status: json['status'] ?? 'active',
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
      refillsAllowed: json['refills_allowed'] ?? 0,
      refillsUsed: json['refills_used'] ?? 0,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescription_id': prescriptionId,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'patient_name': patientName,
      'medication_name': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'duration_days': durationDays,
      'instructions': instructions,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'refills_allowed': refillsAllowed,
      'refills_used': refillsUsed,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get canRefill => refillsAllowed > refillsUsed && status == 'active';
  bool get isExpired => DateTime.now().isAfter(endDate);
  int get refillsRemaining => refillsAllowed - refillsUsed;

  Prescription copyWith({
    String? prescriptionId,
    String? doctorId,
    String? patientId,
    String? patientName,
    String? medicationName,
    String? dosage,
    String? frequency,
    int? durationDays,
    String? instructions,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? refillsAllowed,
    int? refillsUsed,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Prescription(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      durationDays: durationDays ?? this.durationDays,
      instructions: instructions ?? this.instructions,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      refillsAllowed: refillsAllowed ?? this.refillsAllowed,
      refillsUsed: refillsUsed ?? this.refillsUsed,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class HealthRecord {
  final String recordId;
  final String patientId;
  final String recordType;
  final String title;
  final String? description;
  final String? doctorId;
  final String? doctorName;
  final DateTime recordedDate;
  final String? fileUrl;
  final Map<String, dynamic>? metadata;
  final String visibility;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HealthRecord({
    required this.recordId,
    required this.patientId,
    required this.recordType,
    required this.title,
    this.description,
    this.doctorId,
    this.doctorName,
    required this.recordedDate,
    this.fileUrl,
    this.metadata,
    required this.visibility,
    required this.createdAt,
    this.updatedAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      recordId: json['record_id'] ?? '',
      patientId: json['patient_id'] ?? '',
      recordType: json['record_type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      doctorId: json['doctor_id'],
      doctorName: json['doctor_name'],
      recordedDate: DateTime.parse(json['recorded_date'] ?? DateTime.now().toIso8601String()),
      fileUrl: json['file_url'],
      metadata: json['metadata'],
      visibility: json['visibility'] ?? 'private',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'record_id': recordId,
      'patient_id': patientId,
      'record_type': recordType,
      'title': title,
      'description': description,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'recorded_date': recordedDate.toIso8601String(),
      'file_url': fileUrl,
      'metadata': metadata,
      'visibility': visibility,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  HealthRecord copyWith({
    String? recordId,
    String? patientId,
    String? recordType,
    String? title,
    String? description,
    String? doctorId,
    String? doctorName,
    DateTime? recordedDate,
    String? fileUrl,
    Map<String, dynamic>? metadata,
    String? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthRecord(
      recordId: recordId ?? this.recordId,
      patientId: patientId ?? this.patientId,
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      description: description ?? this.description,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      recordedDate: recordedDate ?? this.recordedDate,
      fileUrl: fileUrl ?? this.fileUrl,
      metadata: metadata ?? this.metadata,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DoctorRating {
  final String ratingId;
  final String doctorId;
  final String patientId;
  final String? patientName;
  final String? appointmentId;
  final int rating;
  final String? reviewText;
  final bool anonymous;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DoctorRating({
    required this.ratingId,
    required this.doctorId,
    required this.patientId,
    this.patientName,
    this.appointmentId,
    required this.rating,
    this.reviewText,
    required this.anonymous,
    required this.helpfulCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory DoctorRating.fromJson(Map<String, dynamic> json) {
    return DoctorRating(
      ratingId: json['rating_id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      patientId: json['patient_id'] ?? '',
      patientName: json['patient_name'],
      appointmentId: json['appointment_id'],
      rating: json['rating'] ?? 5,
      reviewText: json['review_text'],
      anonymous: json['anonymous'] ?? false,
      helpfulCount: json['helpful_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating_id': ratingId,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'patient_name': patientName,
      'appointment_id': appointmentId,
      'rating': rating,
      'review_text': reviewText,
      'anonymous': anonymous,
      'helpful_count': helpfulCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class DoctorAvailability {
  final String availabilityId;
  final int dayOfWeek; // 0=Monday, 6=Sunday
  final String startTime; // "09:00"
  final String endTime; // "17:00"
  final int slotDurationMinutes;
  final bool isActive;

  DoctorAvailability({
    required this.availabilityId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotDurationMinutes,
    required this.isActive,
  });

  factory DoctorAvailability.fromJson(Map<String, dynamic> json) {
    return DoctorAvailability(
      availabilityId: json['availability_id'] ?? '',
      dayOfWeek: json['day_of_week'] ?? 0,
      startTime: json['start_time'] ?? '09:00',
      endTime: json['end_time'] ?? '17:00',
      slotDurationMinutes: json['slot_duration_minutes'] ?? 30,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availability_id': availabilityId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'slot_duration_minutes': slotDurationMinutes,
      'is_active': isActive,
    };
  }

  String get dayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek];
  }
}

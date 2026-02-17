import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import '../services/token_storage.dart';
import '../models/phase3_models.dart';

class DoctorService {
  static const String baseUrl = '${ApiService.baseUrl}/api/v1/doctor';
  late String _token;

  Future<void> _initToken() async {
    _token = await TokenStorage.read('token') ?? '';
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  // ==================== Doctor Profile ====================

  Future<DoctorProfile> getDoctorProfile() async {
    await _initToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return DoctorProfile.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch doctor profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Specialization> addSpecialization({
    required String specialty,
    required String licenseNumber,
    required String issuingCountry,
    required DateTime issueDate,
    DateTime? expiryDate,
  }) async {
    await _initToken();
    try {
      final body = {
        'specialty': specialty,
        'license_number': licenseNumber,
        'issuing_country': issuingCountry,
        'issue_date': issueDate.toIso8601String(),
        if (expiryDate != null) 'expiry_date': expiryDate.toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/specializations'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Specialization.fromJson(data);
      } else {
        throw Exception('Failed to add specialization');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Specialization>> getSpecializations() async {
    await _initToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/specializations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final specs = data['specializations'] as List?;
        return specs?.map((s) => Specialization.fromJson(s)).toList() ?? [];
      } else {
        throw Exception('Failed to fetch specializations');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== Prescriptions ====================

  Future<Prescription> createPrescription({
    required String patientId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required int durationDays,
    String? instructions,
    int refillsAllowed = 0,
    String? notes,
  }) async {
    await _initToken();
    try {
      final body = {
        'patient_id': patientId,
        'medication_name': medicationName,
        'dosage': dosage,
        'frequency': frequency,
        'duration_days': durationDays,
        if (instructions != null) 'instructions': instructions,
        'refills_allowed': refillsAllowed,
        if (notes != null) 'notes': notes,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/prescriptions'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return Prescription.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create prescription');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Prescription>> getPrescriptions({
    String? status,
    int skip = 0,
    int limit = 20,
  }) async {
    await _initToken();
    try {
      String url = '$baseUrl/prescriptions?skip=$skip&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prescriptions = data['prescriptions'] as List?;
        return prescriptions?.map((p) => Prescription.fromJson(p)).toList() ?? [];
      } else {
        throw Exception('Failed to fetch prescriptions');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Prescription> getPrescription(String prescriptionId) async {
    await _initToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prescriptions/$prescriptionId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Prescription.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch prescription');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Prescription> updatePrescription(
    String prescriptionId, {
    String? status,
    String? notes,
  }) async {
    await _initToken();
    try {
      final body = {
        if (status != null) 'status': status,
        if (notes != null) 'notes': notes,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/prescriptions/$prescriptionId'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return Prescription.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update prescription');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> approvePrescriptionRefill(String prescriptionId) async {
    await _initToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/prescriptions/$prescriptionId/refill'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== Health Records ====================

  Future<HealthRecord> createHealthRecord({
    required String patientId,
    required String recordType,
    required String title,
    String? description,
    DateTime? recordedDate,
    String? fileUrl,
    Map<String, dynamic>? metadata,
  }) async {
    await _initToken();
    try {
      final body = {
        'patient_id': patientId,
        'record_type': recordType,
        'title': title,
        if (description != null) 'description': description,
        'recorded_date': (recordedDate ?? DateTime.now()).toIso8601String(),
        if (fileUrl != null) 'file_url': fileUrl,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/health-records'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return HealthRecord.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create health record');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<HealthRecord>> getPatientHealthRecords(String patientId) async {
    await _initToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patients/$patientId/health-records'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final records = data['records'] as List?;
        return records?.map((r) => HealthRecord.fromJson(r)).toList() ?? [];
      } else {
        throw Exception('Failed to fetch health records');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== Availability ====================

  Future<DoctorAvailability> setAvailability({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    int slotDurationMinutes = 30,
  }) async {
    await _initToken();
    try {
      final body = {
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'slot_duration_minutes': slotDurationMinutes,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/availability'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return DoctorAvailability.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to set availability');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<DoctorAvailability>> getAvailability() async {
    await _initToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/availability'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final availability = data['availability'] as List?;
        return availability?.map((a) => DoctorAvailability.fromJson(a)).toList() ?? [];
      } else {
        throw Exception('Failed to fetch availability');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== Dashboard ====================

  Future<Map<String, dynamic>> getDoctorDashboard() async {
    await _initToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch dashboard');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getRatings() async {
    await _initToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ratings'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch ratings');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== Appointments ====================

  Future<List<dynamic>> getPendingAppointments() async {
    await _initToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/pending'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['appointments'] as List? ?? [];
      } else {
        throw Exception('Failed to fetch pending appointments');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> acceptAppointment(String appointmentId) async {
    await _initToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments/$appointmentId/accept'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> rejectAppointment(String appointmentId, String reason) async {
    await _initToken();
    try {
      final body = {'reason': reason};

      final response = await http.post(
        Uri.parse('$baseUrl/appointments/$appointmentId/reject'),
        headers: _headers,
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

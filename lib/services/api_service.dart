import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Production URL
  // static const String baseUrl = 'http://ec2-52-66-232-144.ap-south-1.compute.amazonaws.com';
  // Local Development
  static const String baseUrl = 'http://localhost:8000';

  // ─── Auth headers ───
  static Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // ════════════════════════════════════
  //              AUTH
  // ════════════════════════════════════

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required String role,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'role': role,
      }),
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) return jsonDecode(resp.body);
    final err = jsonDecode(resp.body);
    throw Exception(err['detail'] ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> registerPatientByDoctor({
    required String name,
    String? email,
    String? password,
    required int age,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/register-patient'),
      headers: _headers(token),
      body: jsonEncode({
        'name': name,
        'age': age,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
      }),
    );
    // Parse response
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
        throw Exception(jsonDecode(resp.body)['detail'] ?? 'Registration failed');
    }
  }

  static Future<void> linkRecords({required String code, required String token}) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/patients/link?share_code=$code'),
      headers: _headers(token),
    );
    if (resp.statusCode != 200) {
        throw Exception(jsonDecode(resp.body)['detail'] ?? 'Linking failed');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    final err = jsonDecode(resp.body);
    throw Exception(err['detail'] ?? 'Login failed');
  }

  // ════════════════════════════════════
  //           HEALTH LOGS
  // ════════════════════════════════════

  static Future<Map<String, dynamic>> createHealthLog({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/health-logs'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to create health log');
  }

  static Future<List<dynamic>> getHealthLogs({
    required String userId,
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/health-logs?user_id=$userId'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to fetch health logs');
  }

  static Future<Map<String, dynamic>> updateHealthLog({
    required String logId,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/health-logs/$logId'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to update health log');
  }

  static Future<void> deleteHealthLog({
    required String logId,
    required String token,
  }) async {
    final resp = await http.delete(
      Uri.parse('$baseUrl/health-logs/$logId'),
      headers: _headers(token),
    );
    if (resp.statusCode != 200) throw Exception('Failed to delete');
  }

  // ════════════════════════════════════
  //           CHAT
  // ════════════════════════════════════

  static Future<Map<String, dynamic>> sendChat({
    required String message,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: _headers(token),
      body: jsonEncode({'message': message}),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Chat failed');
  }

  // ════════════════════════════════════
  //        SYMPTOM CHECKER
  // ════════════════════════════════════

  static Future<Map<String, dynamic>> checkSymptoms({
    required String symptoms,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/symptom-check'),
      headers: _headers(token),
      body: jsonEncode({'symptoms': symptoms}),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Symptom check failed');
  }

  // ════════════════════════════════════
  //        PREGNANCY PROFILE
  // ════════════════════════════════════

  static Future<Map<String, dynamic>> createPregnancyProfile({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/pregnancy-profile'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    final err = jsonDecode(resp.body);
    throw Exception(err['detail'] ?? 'Failed to create pregnancy profile');
  }

  static Future<Map<String, dynamic>> getPregnancyProfile({
    required String userId,
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/pregnancy-profile/$userId'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    if (resp.statusCode == 404) return {};
    throw Exception('Failed to fetch pregnancy profile');
  }

  static Future<Map<String, dynamic>> updatePregnancyProfile({
    required String userId,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/pregnancy-profile/$userId'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to update pregnancy profile');
  }

  // ════════════════════════════════════
  //        DOCTOR / LINKING
  // ════════════════════════════════════

  static Future<Map<String, dynamic>> createDoctorProfile({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/doctor-profile'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to create doctor profile');
  }

  static Future<Map<String, dynamic>> getDoctorProfile({
    required String userId,
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/doctor-profile/$userId'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    if (resp.statusCode == 404) return {};
    throw Exception('Failed to fetch doctor profile');
  }

  static Future<Map<String, dynamic>> linkDoctor({
    required String patientId,
    required String inviteCode,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/link-doctor'),
      headers: _headers(token),
      body: jsonEncode({'patient_id': patientId, 'invite_code': inviteCode}),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    final err = jsonDecode(resp.body);
    throw Exception(err['detail'] ?? 'Failed to link doctor');
  }

  static Future<Map<String, dynamic>> getMyDoctor({
    required String patientId,
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/my-doctor/$patientId'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return {'linked': false};
  }

  static Future<List<dynamic>> getMyPatients({
    required String doctorId,
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/my-patients/$doctorId'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  // ════════════════════════════════════
  //        MEDICAL REPORTS
  // ════════════════════════════════════

  static Future<Map<String, dynamic>> createReport({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/reports'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to create report');
  }

  static Future<List<dynamic>> getReports({
    required String patientId,
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/reports/$patientId'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  static Future<void> deleteReport({
    required String reportId,
    required String token,
  }) async {
    final resp = await http.delete(
      Uri.parse('$baseUrl/reports/$reportId'),
      headers: _headers(token),
    );
    if (resp.statusCode != 200) throw Exception('Failed to delete report');
  }

  // ════════════════════════════════════
  //        MEDICATIONS
  // ════════════════════════════════════

  static Future<Map<String, dynamic>> createMedication({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/medications'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to create medication');
  }

  static Future<List<dynamic>> getMedications({
    required String patientId,
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/medications/$patientId'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  static Future<void> deleteMedication({
    required String medId,
    required String token,
  }) async {
    final resp = await http.delete(
      Uri.parse('$baseUrl/medications/$medId'),
      headers: _headers(token),
    );
    if (resp.statusCode != 200) throw Exception('Failed to delete medication');
  }

  // ════════════════════════════════════
  //        DIET PLANS
  // ════════════════════════════════════

  static Future<Map<String, dynamic>> createDietPlan({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/diet-plans'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to create diet plan');
  }

  static Future<List<dynamic>> getDietPlans({
    required String patientId,
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/diet-plans/$patientId'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  static Future<void> deleteDietPlan({
    required String planId,
    required String token,
  }) async {
    final resp = await http.delete(
      Uri.parse('$baseUrl/diet-plans/$planId'),
      headers: _headers(token),
    );
    if (resp.statusCode != 200) throw Exception('Failed to delete diet plan');
  }

  // ════════════════════════════════════
  //        EMERGENCY
  // ════════════════════════════════════

  static Future<Map<String, dynamic>> createEmergency({
    required String patientId,
    required String message,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/emergency'),
      headers: _headers(token),
      body: jsonEncode({'patient_id': patientId, 'message': message}),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to create emergency request');
  }

  static Future<List<dynamic>> getPendingEmergencies({
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/emergencies/pending'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  static Future<List<dynamic>> getMyEmergencies({
    required String patientId,
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/emergencies/$patientId'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  static Future<Map<String, dynamic>> acceptEmergency({
    required String emergencyId,
    required String consultationType,
    required String token,
  }) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/emergency/$emergencyId/accept?consultation_type=$consultationType'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to accept emergency');
  }

  // ════════════════════════════════════
  //        PHASE 2: ADVANCED FEATURES
  // ════════════════════════════════════

  static Future<void> updatePermissions({
    required String doctorId,
    required Map<String, bool> permissions,
    required String token,
  }) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/doctor/permissions'),
      headers: _headers(token),
      body: jsonEncode({'doctor_id': doctorId, 'permissions': permissions}),
    );
    if (resp.statusCode != 200) throw Exception('Failed to update permissions');
  }

  static Future<List<dynamic>> getMyDoctors({
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/my-doctors'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  static Future<Map<String, dynamic>> updateMedicalHistory({
    required String patientId,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/medical-history/$patientId'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to update medical history');
  }

  static Future<Map<String, dynamic>> getMedicalHistory({
    required String patientId,
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/medical-history/$patientId'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return {};
  }

  static Future<Map<String, dynamic>> createConsultation({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/consultations'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to create consultation');
  }

  static Future<List<dynamic>> getConsultations({
    required String patientId,
    required String token,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/consultations/$patientId'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  static Future<void> payConsultation({
    required String consultationId,
    required String token,
  }) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/consultations/$consultationId/pay'),
      headers: _headers(token),
    );
    if (resp.statusCode != 200) throw Exception('Payment failed');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Production URL (Render)
  static const String baseUrl = 'https://hercare-backend.onrender.com';
  // Local Development (uncomment to use)
  // static const String baseUrl = 'http://127.0.0.1:8001';

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
    final resp = await http.post(Uri.parse(
      '$baseUrl/register?name=${Uri.encodeComponent(name)}&email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}&age=$age&role=$role',
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    final err = jsonDecode(resp.body);
    throw Exception(err['detail'] ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final resp = await http.post(Uri.parse(
      '$baseUrl/login?email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}',
    ));
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
}

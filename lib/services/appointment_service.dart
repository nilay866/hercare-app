import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/phase2_models.dart';

class AppointmentService {
  static const String baseUrl = 'http://localhost:8000';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<List<Appointment>> getMyAppointments() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/appointments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Appointment> appointments = (data['appointments'] as List)
            .map((a) => Appointment.fromJson(a))
            .toList();
        return appointments;
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      print('Error getting appointments: $e');
      rethrow;
    }
  }

  Future<Appointment> getAppointment(String appointmentId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/$appointmentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Appointment.fromJson(data);
      } else {
        throw Exception('Failed to load appointment');
      }
    } catch (e) {
      print('Error getting appointment: $e');
      rethrow;
    }
  }

  Future<Appointment> bookAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    required String appointmentType,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'doctor_id': doctorId,
          'appointment_date': appointmentDate.toIso8601String(),
          'appointment_type': appointmentType,
          'notes': notes,
          'duration_minutes': 30,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Appointment.fromJson(data);
      } else {
        throw Exception('Failed to book appointment');
      }
    } catch (e) {
      print('Error booking appointment: $e');
      rethrow;
    }
  }

  Future<Appointment> updateAppointment(
    String appointmentId, {
    DateTime? appointmentDate,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/appointments/$appointmentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (appointmentDate != null) 'appointment_date': appointmentDate.toIso8601String(),
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Appointment.fromJson(data);
      } else {
        throw Exception('Failed to update appointment');
      }
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  Future<void> cancelAppointment(
    String appointmentId, {
    String? cancellationReason,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/appointments/$appointmentId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (cancellationReason != null) 'cancellation_reason': cancellationReason,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      print('Error cancelling appointment: $e');
      rethrow;
    }
  }

  Future<List<Appointment>> getDoctorAvailability(String doctorId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/doctors/$doctorId/availability'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Appointment> slots = (data['available_slots'] as List)
            .map((s) => Appointment.fromJson(s))
            .toList();
        return slots;
      } else {
        throw Exception('Failed to load availability');
      }
    } catch (e) {
      print('Error getting availability: $e');
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import '../models/phase2_models.dart';
import '../services/appointment_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _service = AppointmentService();

  List<Appointment> _appointments = [];
  Appointment? _selectedAppointment;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Appointment> get appointments => _appointments;
  Appointment? get selectedAppointment => _selectedAppointment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get upcoming appointments
  List<Appointment> get upcomingAppointments {
    return _appointments
        .where((a) => a.appointmentDate.isAfter(DateTime.now()) && a.status == 'scheduled')
        .toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  // Get past appointments
  List<Appointment> get pastAppointments {
    return _appointments
        .where((a) => a.appointmentDate.isBefore(DateTime.now()) || a.status != 'scheduled')
        .toList()
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
  }

  // Load all appointments
  Future<void> loadAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = await _service.getMyAppointments();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load single appointment
  Future<void> loadAppointment(String appointmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedAppointment = await _service.getAppointment(appointmentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Book appointment
  Future<Appointment?> bookAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    required String appointmentType,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final appointment = await _service.bookAppointment(
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        appointmentType: appointmentType,
        notes: notes,
      );
      _appointments.add(appointment);
      _error = null;
      return appointment;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update appointment
  Future<bool> updateAppointment(
    String appointmentId, {
    DateTime? appointmentDate,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateAppointment(
        appointmentId,
        appointmentDate: appointmentDate,
        notes: notes,
      );
      
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index >= 0) {
        _appointments[index] = updated;
      }
      
      if (_selectedAppointment?.id == appointmentId) {
        _selectedAppointment = updated;
      }
      
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel appointment
  Future<bool> cancelAppointment(
    String appointmentId, {
    String? cancellationReason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.cancelAppointment(appointmentId, cancellationReason: cancellationReason);
      
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index >= 0) {
        _appointments[index] = _appointments[index].copyWith(status: 'cancelled');
      }
      
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get doctor availability
  Future<List<Appointment>> getDoctorAvailability(String doctorId) async {
    try {
      return await _service.getDoctorAvailability(doctorId);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

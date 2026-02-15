import 'package:flutter/material.dart';
import '../models/phase3_models.dart';
import '../services/doctor_service.dart';

class DoctorProvider extends ChangeNotifier {
  final DoctorService _service = DoctorService();

  DoctorProfile? _doctorProfile;
  List<Specialization> _specializations = [];
  List<Prescription> _prescriptions = [];
  List<HealthRecord> _healthRecords = [];
  List<DoctorAvailability> _availability = [];
  Map<String, dynamic> _dashboardData = {};
  Map<String, dynamic> _ratings = {};
  List<dynamic> _pendingAppointments = [];
  
  bool _isLoading = false;
  String? _error;

  // Getters
  DoctorProfile? get doctorProfile => _doctorProfile;
  List<Specialization> get specializations => _specializations;
  List<Prescription> get prescriptions => _prescriptions;
  List<HealthRecord> get healthRecords => _healthRecords;
  List<DoctorAvailability> get availability => _availability;
  Map<String, dynamic> get dashboardData => _dashboardData;
  Map<String, dynamic> get ratings => _ratings;
  List<dynamic> get pendingAppointments => _pendingAppointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get active prescriptions
  List<Prescription> get activePrescriptions {
    return _prescriptions.where((p) => p.status == 'active').toList();
  }

  // Get expired prescriptions
  List<Prescription> get expiredPrescriptions {
    return _prescriptions.where((p) => p.isExpired).toList();
  }

  // Load doctor profile
  Future<void> loadDoctorProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _doctorProfile = await _service.getDoctorProfile();
      _specializations = await _service.getSpecializations();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add specialization
  Future<bool> addSpecialization({
    required String specialty,
    required String licenseNumber,
    required String issuingCountry,
    required DateTime issueDate,
    DateTime? expiryDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final spec = await _service.addSpecialization(
        specialty: specialty,
        licenseNumber: licenseNumber,
        issuingCountry: issuingCountry,
        issueDate: issueDate,
        expiryDate: expiryDate,
      );
      
      _specializations.add(spec);
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

  // Load prescriptions
  Future<void> loadPrescriptions({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prescriptions = await _service.getPrescriptions(status: status);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create prescription
  Future<bool> createPrescription({
    required String patientId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required int durationDays,
    String? instructions,
    int refillsAllowed = 0,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prescription = await _service.createPrescription(
        patientId: patientId,
        medicationName: medicationName,
        dosage: dosage,
        frequency: frequency,
        durationDays: durationDays,
        instructions: instructions,
        refillsAllowed: refillsAllowed,
        notes: notes,
      );
      
      _prescriptions.insert(0, prescription);
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

  // Approve prescription refill
  Future<bool> approvePrescriptionRefill(String prescriptionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.approvePrescriptionRefill(prescriptionId);
      
      if (success) {
        final index = _prescriptions.indexWhere((p) => p.prescriptionId == prescriptionId);
        if (index >= 0) {
          final prescription = _prescriptions[index];
          _prescriptions[index] = prescription.copyWith(
            refillsUsed: prescription.refillsUsed + 1,
          );
        }
      }
      
      _error = null;
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load health records
  Future<void> loadHealthRecords(String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _healthRecords = await _service.getPatientHealthRecords(patientId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create health record
  Future<bool> createHealthRecord({
    required String patientId,
    required String recordType,
    required String title,
    String? description,
    DateTime? recordedDate,
    String? fileUrl,
    Map<String, dynamic>? metadata,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final record = await _service.createHealthRecord(
        patientId: patientId,
        recordType: recordType,
        title: title,
        description: description,
        recordedDate: recordedDate,
        fileUrl: fileUrl,
        metadata: metadata,
      );
      
      _healthRecords.insert(0, record);
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

  // Load availability
  Future<void> loadAvailability() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availability = await _service.getAvailability();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set availability
  Future<bool> setAvailability({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    int slotDurationMinutes = 30,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final avail = await _service.setAvailability(
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        slotDurationMinutes: slotDurationMinutes,
      );
      
      _availability.add(avail);
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

  // Load dashboard
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _service.getDoctorDashboard();
      _ratings = await _service.getRatings();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load pending appointments
  Future<void> loadPendingAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingAppointments = await _service.getPendingAppointments();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Accept appointment
  Future<bool> acceptAppointment(String appointmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.acceptAppointment(appointmentId);
      
      if (success) {
        _pendingAppointments.removeWhere(
          (a) => a['appointment_id'] == appointmentId,
        );
      }
      
      _error = null;
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reject appointment
  Future<bool> rejectAppointment(String appointmentId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.rejectAppointment(appointmentId, reason);
      
      if (success) {
        _pendingAppointments.removeWhere(
          (a) => a['appointment_id'] == appointmentId,
        );
      }
      
      _error = null;
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

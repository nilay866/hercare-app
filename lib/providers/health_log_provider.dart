import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/health_log.dart';
import '../services/api_service.dart';

class HealthLogProvider extends ChangeNotifier {
  List<HealthLog> _logs = [];
  List<Map<String, dynamic>> _pendingLogs = [];
  bool _isLoading = false;
  double _avgPain = 0;
  HealthLog? _lastLog;
  String? _nextPeriod;

  List<HealthLog> get logs => _logs;
  bool get isLoading => _isLoading;
  double get avgPain => _avgPain;
  HealthLog? get lastLog => _lastLog;
  String? get nextPeriod => _nextPeriod;
  int get pendingCount => _pendingLogs.length;

  // ─── Fetch Logs ───
  Future<void> fetchLogs(String userId, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.getHealthLogs(userId: userId, token: token);
      _logs = data.map((j) => HealthLog.fromJson(j)).toList();
      _cacheToHive();
    } catch (_) {
      // Load from Hive cache if offline
      await _loadFromHive();
    }

    _computeStats();
    _isLoading = false;
    notifyListeners();
  }

  // ─── Add Log (with offline support) ───
  Future<void> addLog(Map<String, dynamic> logData, String token) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) {
        throw Exception('No internet');
      }
      await ApiService.createHealthLog(body: logData, token: token);
    } catch (_) {
      // Save to pending queue
      _pendingLogs.add(logData);
      await _savePending();
    }
    notifyListeners();
  }

  // ─── Update Log ───
  Future<void> updateLog(String logId, Map<String, dynamic> body, String token) async {
    await ApiService.updateHealthLog(logId: logId, body: body, token: token);
  }

  // ─── Delete Log ───
  Future<void> deleteLog(String logId, String token) async {
    await ApiService.deleteHealthLog(logId: logId, token: token);
    _logs.removeWhere((l) => l.id == logId);
    _computeStats();
    notifyListeners();
  }

  // ─── Sync pending logs ───
  Future<int> syncPending(String token) async {
    await _loadPending();
    if (_pendingLogs.isEmpty) return 0;

    int synced = 0;
    final remaining = <Map<String, dynamic>>[];

    for (final log in _pendingLogs) {
      try {
        await ApiService.createHealthLog(body: log, token: token);
        synced++;
      } catch (_) {
        remaining.add(log);
      }
    }

    _pendingLogs = remaining;
    await _savePending();
    notifyListeners();
    return synced;
  }

  // ─── Compute stats ───
  void _computeStats() {
    if (_logs.isEmpty) {
      _avgPain = 0;
      _lastLog = null;
      _nextPeriod = null;
      return;
    }
    _lastLog = _logs.first;
    _avgPain = _logs.map((l) => l.painLevel).reduce((a, b) => a + b) / _logs.length;

    // Cycle prediction: find period logs, estimate next
    final periodLogs = _logs.where((l) => l.logType == 'period').toList();
    if (periodLogs.length >= 2) {
      final d1 = DateTime.tryParse(periodLogs[0].logDate);
      final d2 = DateTime.tryParse(periodLogs[1].logDate);
      if (d1 != null && d2 != null) {
        final cycle = d1.difference(d2).inDays.abs();
        final effectiveCycle = (cycle > 0 && cycle < 60) ? cycle : 28;
        final next = d1.add(Duration(days: effectiveCycle));
        _nextPeriod = '${next.year}-${next.month.toString().padLeft(2, '0')}-${next.day.toString().padLeft(2, '0')}';
      }
    } else if (periodLogs.length == 1) {
      final d = DateTime.tryParse(periodLogs[0].logDate);
      if (d != null) {
        final next = d.add(const Duration(days: 28));
        _nextPeriod = '${next.year}-${next.month.toString().padLeft(2, '0')}-${next.day.toString().padLeft(2, '0')}';
      }
    }
  }

  // ─── Hive cache ───
  Future<void> _cacheToHive() async {
    final box = await Hive.openBox('healthLogsCache');
    await box.put('logs', _logs.map((l) => l.toJson()).toList());
  }

  Future<void> _loadFromHive() async {
    final box = await Hive.openBox('healthLogsCache');
    final cached = box.get('logs');
    if (cached != null) {
      _logs = (cached as List).map((j) => HealthLog.fromJson(Map<String, dynamic>.from(j))).toList();
    }
  }

  Future<void> _savePending() async {
    final box = await Hive.openBox('pendingLogs');
    await box.put('pending', _pendingLogs);
  }

  Future<void> _loadPending() async {
    final box = await Hive.openBox('pendingLogs');
    final data = box.get('pending');
    if (data != null) {
      _pendingLogs = (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/app_logger.dart';
import '../services/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userName;
  String? _role;
  bool _isLoading = true;

  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get role => _role;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;

  // Try auto-login on app start
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _token = await TokenStorage.read('token');
    _token ??= await TokenStorage.read('auth_token'); // Legacy key support
    if (_token != null && _token!.isNotEmpty) {
      await TokenStorage.save('token', _token!);
    }
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _role = prefs.getString('role');
    _isLoading = false;
    notifyListeners();
  }

  // Register
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required String role,
  }) async {
    final data = await ApiService.register(
      name: name,
      email: email,
      password: password,
      age: age,
      role: role,
    );
    final accessToken = _extractAccessToken(data);
    await _saveAuth(accessToken, data['id'].toString(), name, role);
  }

  // Login
  Future<void> login({required String email, required String password}) async {
    final data = await ApiService.login(email: email, password: password);
    final accessToken = _extractAccessToken(data);
    final id = data['id']?.toString();
    if (id == null || id.isEmpty) {
      throw Exception('User id missing in login response');
    }
    await _saveAuth(
      accessToken,
      id,
      data['name']?.toString() ?? '',
      data['role']?.toString(),
    );
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    final prefs = await SharedPreferences.getInstance();
    await TokenStorage.delete('token');
    await TokenStorage.delete('auth_token');
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _saveAuth(
    String token,
    String userId,
    String name,
    String? role,
  ) async {
    _token = token;
    _userId = userId;
    _userName = name;
    _role = role;
    final prefs = await SharedPreferences.getInstance();
    await TokenStorage.save('token', token);
    await TokenStorage.save('auth_token', token); // Keep for compatibility
    await prefs.setString('userId', userId);
    await prefs.setString('userName', name);
    if (role != null) await prefs.setString('role', role);
    await AppLogger.log(
      'AuthProvider',
      'Session saved for user: $userId, role: ${role ?? "unknown"}',
    );
    notifyListeners();
  }

  String _extractAccessToken(Map<String, dynamic> data) {
    final raw = data['access_token'] ?? data['token'];
    final token = raw?.toString() ?? '';
    if (token.isEmpty) {
      throw Exception('Authentication token missing in server response');
    }
    return token;
  }
}

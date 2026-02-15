import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? _userId;
  String? _userName;
  String? _role;
  bool _isLoading = true;

  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get role => _role;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;

  // Try auto-login on app start
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _token = await _storage.read(key: 'token');
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
      name: name, email: email, password: password, age: age, role: role,
    );
    await _saveAuth(data['token'], data['id'], name, role);
  }

  // Login
  Future<void> login({required String email, required String password}) async {
    final data = await ApiService.login(email: email, password: password);
    await _saveAuth(data['token'], data['id'], data['name'], data['role']);
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    final prefs = await SharedPreferences.getInstance();
    await _storage.delete(key: 'token');
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _saveAuth(String token, String userId, String name, String? role) async {
    _token = token;
    _userId = userId;
    _userName = name;
    _role = role;
    final prefs = await SharedPreferences.getInstance();
    await _storage.write(key: 'token', value: token);
    await prefs.setString('userId', userId);
    await prefs.setString('userName', name);
    if (role != null) await prefs.setString('role', role);
    notifyListeners();
  }
}

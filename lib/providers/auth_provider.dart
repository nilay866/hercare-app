import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userName;
  bool _isLoading = true;

  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;

  // Try auto-login on app start
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
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
    await _saveAuth(data['token'], data['id'], name);
  }

  // Login
  Future<void> login({required String email, required String password}) async {
    final data = await ApiService.login(email: email, password: password);
    await _saveAuth(data['token'], data['id'], data['name']);
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _saveAuth(String token, String userId, String name) async {
    _token = token;
    _userId = userId;
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
    await prefs.setString('userName', name);
    notifyListeners();
  }
}

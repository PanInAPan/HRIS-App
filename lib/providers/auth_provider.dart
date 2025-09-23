// lib/providers/auth_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'ADMIN';
  bool get isHR => _user?.role == 'HR' || isAdmin;
  bool get isEmployee => _user?.role == 'KARYAWAN' || isHR;

  Future<void> initialize() async {
    await ApiService.init();
    if (await AuthService.validateToken()) {
      // Token valid, bisa fetch user data
      await fetchUserProfile();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await AuthService.login(email, password);
      _user = authResponse.user;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String email, String password, [String? role]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await AuthService.register(email, password, role);
      _user = authResponse.user;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await ApiService.get('/users/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data['data']);
        notifyListeners();
      }
    } catch (e) {
      // Error fetching profile
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
// lib/services/auth_service.dart
import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:human_resource_information_system_application/models/auth_response.dart';
import 'api_service.dart';

class AuthService {
  static Future<AuthResponse> login(String email, String password) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      await ApiService.saveToken(authResponse.accessToken);
      return authResponse;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Login failed');
    }
  }

  static Future<AuthResponse> register(String email, String password, [String? role]) async {
    final response = await ApiService.post('/auth/register', {
      'email': email,
      'password': password,
      if (role != null) 'role': role,
    });

    if (response.statusCode == 201) {
      // final data = json.decode(response.body);
      // Auto login setelah register
      return await login(email, password);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Registration failed');
    }
  }

  static Future<AuthResponse> adminRegister(String email, String password, String role) async {
    final response = await ApiService.post('/auth/admin/register', {
      'email': email,
      'password': password,
      'role': role,
    });

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Admin registration failed');
    }
  }

  static Future<bool> validateToken() async {
    try {
      final response = await ApiService.get('/users/profile');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
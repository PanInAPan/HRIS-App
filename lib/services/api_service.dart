// lib/services/api_service.dart - COMPLETE VERSION
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.100:3000'; // Sesuaikan dengan IP Anda
  static String? token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  static Future<void> saveToken(String newToken) async {
    token = newToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
  }

  static Future<void> logout() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET method
  static Future<http.Response> get(String endpoint) async {
    print('🌐 GET: $baseUrl$endpoint');
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  // POST method
  static Future<http.Response> post(String endpoint, dynamic data) async {
    print('🌐 POST: $baseUrl$endpoint');
    print('📦 Data: $data');
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
  }

  // PATCH method
  static Future<http.Response> patch(String endpoint, dynamic data) async {
    print('🌐 PATCH: $baseUrl$endpoint');
    print('📦 Data: $data');
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
  }

  // DELETE method - YANG BARU DITAMBAH
  static Future<http.Response> delete(String endpoint) async {
    print('🌐 DELETE: $baseUrl$endpoint');
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  // PUT method (optional)
  static Future<http.Response> put(String endpoint, dynamic data) async {
    print('🌐 PUT: $baseUrl$endpoint');
    print('📦 Data: $data');
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
  }

  // Helper method untuk build query string
  static String buildQueryString(Map<String, dynamic> params) {
    final queryParams = [];
    params.forEach((key, value) {
      if (value != null) {
        queryParams.add('$key=${Uri.encodeQueryComponent(value.toString())}');
      }
    });
    return queryParams.join('&');
  }
}
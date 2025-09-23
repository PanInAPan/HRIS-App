// lib/models/auth_response.dart - FIXED VERSION
import 'package:human_resource_information_system_application/models/user_model.dart';

class AuthResponse {
  final String accessToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 JSON keys: ${json.keys}');
    
    // Convert dynamic keys to String keys
    final Map<String, dynamic> safeJson = json.map((key, value) => 
        MapEntry(key.toString(), value));
    
    // Handle kedua kemungkinan: access_token atau accessToken
    final accessToken = safeJson['access_token'] ?? safeJson['accessToken'];
    final userData = safeJson['user'] ?? safeJson;
    
    if (accessToken == null) {
      throw Exception('Access token not found in response');
    }
    
    if (userData is! Map<String, dynamic>) {
      throw Exception('User data is not in expected format');
    }
    
    return AuthResponse(
      accessToken: accessToken.toString(),
      user: User.fromJson(userData),
    );
  }
}
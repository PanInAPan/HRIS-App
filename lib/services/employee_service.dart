import 'dart:convert';
import '../../../services/api_service.dart';

class EmployeeService {
  // Di employee_service.dart - UPDATE DENGAN HELPER METHOD
static Future<Map<String, dynamic>> getEmployees({
  int page = 1,
  int limit = 10,
  String? search,
  String? status,
  int? departmentId,
  String sortBy = 'fullName',
  String sortOrder = 'asc',
}) async {
  final params = {
    'page': page.toString(),
    'limit': limit.toString(),
    if (search != null && search.isNotEmpty) 'search': search,
    if (status != null && status.isNotEmpty) 'status': status,
    if (departmentId != null) 'departmentId': departmentId.toString(),
    'sortBy': sortBy,
    'sortOrder': sortOrder,
  };

  final queryString = ApiService.buildQueryString(params);
  final response = await ApiService.get('/employees?$queryString');
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load employees: ${response.statusCode}');
  }
}

// HAPUS method _buildQueryString yang lama karena sudah ada di ApiService

  static Future<Map<String, dynamic>> getEmployee(int id) async {
    final response = await ApiService.get('/employees/$id');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load employee: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getMyProfile() async {
    final response = await ApiService.get('/employees/me');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> data) async {
    final response = await ApiService.post('/employees', data);
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to create employee');
    }
  }

  static Future<Map<String, dynamic>> updateEmployee(int id, Map<String, dynamic> data) async {
    final response = await ApiService.patch('/employees/$id', data);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to update employee');
    }
  }

  static Future<Map<String, dynamic>> updateEmployeeStatus(int id, String status) async {
    final response = await ApiService.patch('/employees/$id/status', {'status': status});
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to update status');
    }
  }

  static Future<Map<String, dynamic>> getEmployeeStats() async {
    final response = await ApiService.get('/employees/stats');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stats: ${response.statusCode}');
    }
  }

  static Future<void> deleteEmployee(int id) async {
    final response = await ApiService.delete('/employees/$id');
    
    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to delete employee');
    }
  }
}
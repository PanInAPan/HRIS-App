// lib/features/employees/providers/employee_provider.dart
import 'package:flutter/foundation.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';

class EmployeeProvider with ChangeNotifier {
  List<Employee> _employees = [];
  Employee? _selectedEmployee;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<Employee> get employees => _employees;
  Employee? get selectedEmployee => _selectedEmployee;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Load employees dengan pagination
  Future<void> loadEmployees({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    int? departmentId,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _employees = [];
      _hasMore = true;
    }

    if (!_hasMore && loadMore) return;

    try {
      _setLoading(true);
      _error = null;

      final response = await EmployeeService.getEmployees(
        page: _currentPage,
        limit: limit,
        search: search,
        status: status,
        departmentId: departmentId,
      );

      final List<Employee> newEmployees = (response['data'] as List)
          .map((emp) => Employee.fromJson(emp))
          .toList();

      if (loadMore) {
        _employees.addAll(newEmployees);
      } else {
        _employees = newEmployees;
      }

      _hasMore = newEmployees.length == limit;
      if (loadMore) _currentPage++;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Load single employee
  Future<void> loadEmployee(int id) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await EmployeeService.getEmployee(id);
      _selectedEmployee = Employee.fromJson(response);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Load my profile
  Future<void> loadMyProfile() async {
    try {
      _setLoading(true);
      _error = null;

      final response = await EmployeeService.getMyProfile();
      _selectedEmployee = Employee.fromJson(response);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Create employee
  Future<void> createEmployee(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _error = null;

      await EmployeeService.createEmployee(data);
      
      // Reload list setelah create
      await loadEmployees();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update employee
  Future<void> updateEmployee(int id, Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _error = null;

      await EmployeeService.updateEmployee(id, data);
      
      // Update local data
      if (_selectedEmployee?.id == id) {
        await loadEmployee(id);
      }
      
      // Reload list
      await loadEmployees();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete employee
  Future<void> deleteEmployee(int id) async {
    try {
      _setLoading(true);
      _error = null;

      await EmployeeService.deleteEmployee(id);
      
      // Remove from local list
      _employees.removeWhere((emp) => emp.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update status
  Future<void> updateEmployeeStatus(int id, String status) async {
    try {
      _setLoading(true);
      _error = null;

      await EmployeeService.updateEmployeeStatus(id, status);
      
      // Update local data
      if (_selectedEmployee?.id == id) {
        await loadEmployee(id);
      }
      
      // Update in list
      final index = _employees.indexWhere((emp) => emp.id == id);
      if (index != -1) {
        _employees[index] = _employees[index].copyWith(status: status);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear selected employee
  void clearSelectedEmployee() {
    _selectedEmployee = null;
    notifyListeners();
  }

  // Helper method
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// Extension untuk copyWith method (optional tapi useful)
extension EmployeeExtension on Employee {
  Employee copyWith({
    int? id,
    String? fullName,
    String? nip,
    String? phone,
    String? address,
    DateTime? birthDate,
    String? gender,
    String? position,
    DateTime? joinDate,
    String? status,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    Map<String, dynamic>? user,
    Map<String, dynamic>? department,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nip: nip ?? this.nip,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      position: position ?? this.position,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      user: user ?? this.user,
      department: department ?? this.department,
    );
  }
}
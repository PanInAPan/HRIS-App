import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../providers/employee_provider.dart';
import '../models/employee_model.dart';

class EmployeeFormPage extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormPage({Key? key, this.employee}) : super(key: key);

  @override
  _EmployeeFormPageState createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _emergencyContactPhoneController = TextEditingController();
  final TextEditingController _emergencyContactRelationController = TextEditingController();

  // Form values
  String? _selectedRole;
  String? _selectedGender;
  String? _selectedStatus;
  int? _selectedDepartmentId;
  DateTime? _selectedBirthDate;
  DateTime? _selectedJoinDate;

  // Departments list
  List<Map<String, dynamic>> _departments = [];
  bool _isLoadingDepartments = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.employee != null) {
      final employee = widget.employee!;
      
      _emailController.text = employee.email;
      _fullNameController.text = employee.fullName;
      _nipController.text = employee.nip ?? '';
      _phoneController.text = employee.phone ?? '';
      _addressController.text = employee.address ?? '';
      _positionController.text = employee.position ?? '';
      _emergencyContactNameController.text = employee.emergencyContactName ?? '';
      _emergencyContactPhoneController.text = employee.emergencyContactPhone ?? '';
      _emergencyContactRelationController.text = employee.emergencyContactRelation ?? '';
      
      _selectedRole = employee.role;
      _selectedGender = employee.gender;
      _selectedStatus = employee.status;
      _selectedDepartmentId = employee.department?['id'];
      _selectedBirthDate = employee.birthDate;
      _selectedJoinDate = employee.joinDate;
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final response = await ApiService.get('/departments');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _departments = List<Map<String, dynamic>>.from(data);
          _isLoadingDepartments = false;
        });
      } else {
        throw Exception('Failed to load departments');
      }
    } catch (e) {
      print('Error loading departments: $e');
      setState(() {
        _isLoadingDepartments = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }

    // Password confirmation check
    if (widget.employee == null && _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      // final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final formData = {
        'email': _emailController.text.trim(),
        'fullName': _fullNameController.text.trim(),
        'nip': _nipController.text.trim().isEmpty ? null : _nipController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'position': _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
        'gender': _selectedGender,
        'birthDate': _selectedBirthDate?.toIso8601String(),
        'joinDate': _selectedJoinDate?.toIso8601String(),
        'status': _selectedStatus ?? 'ACTIVE',
        'departmentId': _selectedDepartmentId,
        'emergencyContactName': _emergencyContactNameController.text.trim().isEmpty ? null : _emergencyContactNameController.text.trim(),
        'emergencyContactPhone': _emergencyContactPhoneController.text.trim().isEmpty ? null : _emergencyContactPhoneController.text.trim(),
        'emergencyContactRelation': _emergencyContactRelationController.text.trim().isEmpty ? null : _emergencyContactRelationController.text.trim(),
      };

      // Add role and password only for new employees or if changed
      if (widget.employee == null) {
        formData['password'] = _passwordController.text;
        formData['role'] = _selectedRole ?? 'KARYAWAN';
      } else if (_passwordController.text.isNotEmpty) {
        formData['password'] = _passwordController.text;
      }

      if (widget.employee == null) {
        // Create new employee
        await employeeProvider.createEmployee(formData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee created successfully')),
        );
      } else {
        // Update existing employee
        await employeeProvider.updateEmployee(widget.employee!.id, formData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee updated successfully')),
        );
      }

      Navigator.pop(context); // Kembali ke previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate ? _selectedBirthDate ?? DateTime(1990) : _selectedJoinDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _selectedBirthDate = picked;
        } else {
          _selectedJoinDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: employeeProvider.isLoading ? null : _submitForm,
          ),
        ],
      ),
      body: employeeProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        // Account Information
                        _buildSectionHeader('Account Information'),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        
                        if (widget.employee == null) ...[
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock,
                            obscureText: true,
                            validator: widget.employee == null ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            } : null,
                          ),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: widget.employee == null ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            } : null,
                          ),
                        ] else ...[
                          _buildTextField(
                            controller: _passwordController,
                            label: 'New Password (optional)',
                            icon: Icons.lock,
                            obscureText: true,
                          ),
                        ],
                        
                        if (authProvider.isAdmin && widget.employee == null)
                          _buildDropdown(
                            value: _selectedRole,
                            label: 'Role',
                            icon: Icons.security,
                            items: [
                              DropdownMenuItem(value: null, child: Text('Select Role')),
                              DropdownMenuItem(value: 'KARYAWAN', child: Text('KARYAWAN')),
                              DropdownMenuItem(value: 'HR', child: Text('HR')),
                              if (authProvider.isAdmin)
                                DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                            ],
                            onChanged: (value) => setState(() => _selectedRole = value),
                          ),

                        // Personal Information
                        _buildSectionHeader('Personal Information'),
                        _buildTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter full name';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _nipController,
                          label: 'NIP (Employee ID)',
                          icon: Icons.badge,
                        ),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Address',
                          icon: Icons.location_on,
                          maxLines: 3,
                        ),
                        _buildDropdown(
                          value: _selectedGender,
                          label: 'Gender',
                          icon: Icons.transgender,
                          items: [
                            DropdownMenuItem(value: null, child: Text('Select Gender')),
                            DropdownMenuItem(value: 'MALE', child: Text('Male')),
                            DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                            DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                          ],
                          onChanged: (value) => setState(() => _selectedGender = value),
                        ),
                        _buildDateField(
                          label: 'Birth Date',
                          icon: Icons.cake,
                          date: _selectedBirthDate,
                          onTap: () => _selectDate(context, true),
                        ),

                        // Employment Information
                        _buildSectionHeader('Employment Information'),
                        _buildTextField(
                          controller: _positionController,
                          label: 'Position',
                          icon: Icons.work,
                        ),
                        _buildDropdown(
                          value: _selectedDepartmentId?.toString(),
                          label: 'Department',
                          icon: Icons.business,
                          items: [
                            DropdownMenuItem(value: null, child: Text('Select Department')),
                            ..._departments.map((dept) => DropdownMenuItem(
                              value: dept['id'].toString(),
                              child: Text(dept['name']),
                            )),
                          ],
                          onChanged: (value) => setState(() => _selectedDepartmentId = value != null ? int.parse(value) : null),
                          isLoading: _isLoadingDepartments,
                        ),
                        _buildDateField(
                          label: 'Join Date',
                          icon: Icons.calendar_today,
                          date: _selectedJoinDate,
                          onTap: () => _selectDate(context, false),
                        ),
                        _buildDropdown(
                          value: _selectedStatus,
                          label: 'Status',
                          icon: Icons.circle,
                          items: [
                            DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                            DropdownMenuItem(value: 'PROBATION', child: Text('Probation')),
                            DropdownMenuItem(value: 'CONTRACT', child: Text('Contract')),
                            DropdownMenuItem(value: 'LEAVE', child: Text('On Leave')),
                            DropdownMenuItem(value: 'RESIGN', child: Text('Resigned')),
                          ],
                          onChanged: (value) => setState(() => _selectedStatus = value),
                        ),

                        // Emergency Contact
                        _buildSectionHeader('Emergency Contact'),
                        _buildTextField(
                          controller: _emergencyContactNameController,
                          label: 'Contact Name',
                          icon: Icons.contact_emergency,
                        ),
                        _buildTextField(
                          controller: _emergencyContactPhoneController,
                          label: 'Contact Phone',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          controller: _emergencyContactRelationController,
                          label: 'Relationship',
                          icon: Icons.people,
                        ),

                        // Submit Button
                        SizedBox(height: 32),
                        _buildSubmitButton(employeeProvider),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(Icons.label_important, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    bool isLoading = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
        items: isLoading 
            ? [DropdownMenuItem(value: null, child: Text('Loading...'))]
            : items,
        onChanged: isLoading ? null : onChanged,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date != null 
                    ? '${date.day}/${date.month}/${date.year}'
                    : 'Select Date',
                style: TextStyle(
                  color: date != null ? Colors.black87 : Colors.grey,
                ),
              ),
              Icon(Icons.calendar_today, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(EmployeeProvider employeeProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: employeeProvider.isLoading ? null : _submitForm,
        icon: employeeProvider.isLoading 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.save),
        label: Text(
          employeeProvider.isLoading 
              ? 'Saving...'
              : widget.employee == null ? 'Create Employee' : 'Update Employee',
          style: TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _nipController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _positionController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

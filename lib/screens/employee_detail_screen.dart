// lib/features/employees/pages/employee_detail_page.dart
import 'package:flutter/material.dart';
import 'package:human_resource_information_system_application/screens/employee_form_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../providers/employee_provider.dart';
import '../models/employee_model.dart';

class EmployeeDetailPage extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailPage({Key? key, required this.employeeId}) : super(key: key);

  @override
  _EmployeeDetailPageState createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  void _loadEmployee() {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    employeeProvider.loadEmployee(widget.employeeId);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final employee = employeeProvider.selectedEmployee;

    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Details'),
        actions: [
          if (authProvider.isAdmin || authProvider.isHR)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: employee != null 
                  ? () => _navigateToEdit(employee)
                  : null,
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEmployee,
          ),
        ],
      ),
      body: employeeProvider.isLoading && employee == null
          ? Center(child: CircularProgressIndicator())
          : employeeProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${employeeProvider.error}'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEmployee,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : employee == null
                  ? Center(child: Text('Employee not found'))
                  : _buildEmployeeDetails(employee, authProvider),
    );
  }

  Widget _buildEmployeeDetails(Employee employee, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeaderSection(employee),
          SizedBox(height: 24),
          
          // Personal Information
          _buildSectionTitle('Personal Information'),
          _buildInfoCard([
            _buildInfoRow('Full Name', employee.fullName, Icons.person),
            _buildInfoRow('NIP', employee.nip ?? 'Not specified', Icons.badge),
            _buildInfoRow('Gender', employee.gender ?? 'Not specified', Icons.transgender),
            _buildInfoRow('Birth Date', _formatDate(employee.birthDate), Icons.cake),
          ]),
          SizedBox(height: 16),
          
          // Contact Information
          _buildSectionTitle('Contact Information'),
          _buildInfoCard([
            _buildInfoRow('Email', employee.email, Icons.email),
            _buildInfoRow('Phone', employee.phone ?? 'Not specified', Icons.phone),
            _buildInfoRow('Address', employee.address ?? 'Not specified', Icons.location_on),
          ]),
          SizedBox(height: 16),
          
          // Employment Information
          _buildSectionTitle('Employment Information'),
          _buildInfoCard([
            _buildInfoRow('Position', employee.position ?? 'Not specified', Icons.work),
            _buildInfoRow('Department', employee.departmentName, Icons.business),
            _buildInfoRow('Join Date', employee.formattedJoinDate, Icons.calendar_today),
            _buildInfoRow('Status', employee.formattedStatus, Icons.circle, 
                valueColor: employee.statusColor),
          ]),
          SizedBox(height: 16),
          
          // Emergency Contact
          if (employee.emergencyContactName != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Emergency Contact'),
                _buildInfoCard([
                  _buildInfoRow('Name', employee.emergencyContactName!, Icons.contact_emergency),
                  _buildInfoRow('Phone', employee.emergencyContactPhone ?? 'Not specified', Icons.phone),
                  _buildInfoRow('Relation', employee.emergencyContactRelation ?? 'Not specified', Icons.people),
                ]),
              ],
            ),
          
          // Action Buttons (for admin/hr)
          if (authProvider.isAdmin || authProvider.isHR)
            _buildActionButtons(employee, authProvider),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Employee employee) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: employee.statusColor.withOpacity(0.2),
              child: Text(
                employee.fullName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: employee.statusColor,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    employee.position ?? 'No position',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Chip(
                    label: Text(
                      employee.formattedStatus,
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: employee.statusColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue[700],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Employee employee, AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Management Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Status Update Buttons
                if (employee.status != 'ACTIVE')
                  _buildStatusButton('Set Active', 'ACTIVE', Colors.green, employee),
                
                if (employee.status != 'RESIGN')
                  _buildStatusButton('Set Resigned', 'RESIGN', Colors.red, employee),
                
                if (employee.status != 'LEAVE')
                  _buildStatusButton('Set On Leave', 'LEAVE', Colors.blue, employee),
                
                // Edit Button
                ElevatedButton.icon(
                  onPressed: () => _navigateToEdit(employee),
                  icon: Icon(Icons.edit),
                  label: Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                
                // Delete Button (Admin only)
                if (authProvider.isAdmin)
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteDialog(employee),
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String text, String status, Color color, Employee employee) {
    return ElevatedButton.icon(
      onPressed: () => _updateStatus(employee, status),
      icon: Icon(Icons.update, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _navigateToEdit(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeFormPage(employee: employee),
      ),
    ).then((_) => _loadEmployee());
  }

  void _updateStatus(Employee employee, String status) async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    
    try {
      await employeeProvider.updateEmployeeStatus(employee.id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showDeleteDialog(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
              try {
                await employeeProvider.deleteEmployee(employee.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Employee deleted successfully')),
                );
                Navigator.pop(context); // Kembali ke list page
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not specified';
    return '${date.day}/${date.month}/${date.year}';
  }
}
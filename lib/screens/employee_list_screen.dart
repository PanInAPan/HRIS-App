// lib/features/employees/pages/employee_list_page.dart - UPDATED WITH PROVIDER
import 'package:flutter/material.dart';
import 'package:human_resource_information_system_application/screens/employee_detail_screen.dart';
import 'package:human_resource_information_system_application/screens/employee_form_screen.dart';
import 'package:human_resource_information_system_application/widgets/employee_card.dart';
import 'package:human_resource_information_system_application/widgets/employee_stats_card.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../providers/employee_provider.dart'; // ← IMPORT PROVIDER
import '../models/employee_model.dart';

class EmployeeListPage extends StatefulWidget {
  @override
  _EmployeeListPageState createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  void _loadEmployees({bool loadMore = false}) {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    
    employeeProvider.loadEmployees(
      page: loadMore ? null : 1,
      limit: _limit,
      search: _searchController.text.isEmpty ? null : _searchController.text,
      status: _selectedStatus,
      loadMore: loadMore,
    );
  }

  void _onSearch() {
    _loadEmployees(loadMore: false);
  }

  void _onFilterChanged() {
    _loadEmployees(loadMore: false);
  }

  void _refresh() {
    _loadEmployees(loadMore: false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Employees'),
        actions: [
          if (authProvider.isAdmin || authProvider.isHR)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _navigateToEmployeeForm(),
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(),
          
          // Statistics Card
          if (authProvider.isAdmin || authProvider.isHR)
            EmployeeStatsCard(onTap: _refresh),
          
          // Loading Indicator
          if (employeeProvider.isLoading && employeeProvider.employees.isEmpty)
            LinearProgressIndicator(),
          
          // Error Message
          if (employeeProvider.error != null)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.red[100],
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text('Error: ${employeeProvider.error}')),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: employeeProvider.clearError,
                  ),
                ],
              ),
            ),
          
          // Employee List
          Expanded(
            child: employeeProvider.employees.isEmpty && !employeeProvider.isLoading
                ? Center(child: Text('No employees found'))
                : RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: ListView.builder(
                      itemCount: employeeProvider.employees.length + (employeeProvider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == employeeProvider.employees.length) {
                          return _buildLoadMoreIndicator(employeeProvider);
                        }
                        
                        final employee = employeeProvider.employees[index];
                        return EmployeeCard(
                          employee: employee,
                          onTap: () => _navigateToEmployeeDetail(employee),
                          onEdit: (authProvider.isAdmin || authProvider.isHR)
                              ? () => _navigateToEmployeeForm(employee)
                              : null,
                          onDelete: (authProvider.isAdmin)
                              ? () => _showDeleteDialog(employeeProvider, employee)
                              : null,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search employees...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch();
                  },
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
            SizedBox(height: 10),
            
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text('All Status')),
                DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                DropdownMenuItem(value: 'RESIGN', child: Text('Resigned')),
                DropdownMenuItem(value: 'CONTRACT', child: Text('Contract')),
                DropdownMenuItem(value: 'PROBATION', child: Text('Probation')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _onFilterChanged();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(EmployeeProvider provider) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: provider.isLoading 
            ? CircularProgressIndicator()
            : TextButton(
                onPressed: provider.hasMore ? () => _loadEmployees(loadMore: true) : null,
                child: Text('Load More'),
              ),
      ),
    );
  }

  void _navigateToEmployeeDetail(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailPage(employeeId: employee.id),
      ),
    );
  }

  void _navigateToEmployeeForm([Employee? employee]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeFormPage(employee: employee),
      ),
    ).then((_) => _refresh());
  }

  void _showDeleteDialog(EmployeeProvider provider, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.deleteEmployee(employee.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Employee deleted successfully')),
                );
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
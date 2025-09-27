// lib/features/employees/widgets/employee_stats_card.dart
import 'package:flutter/material.dart';
import 'package:human_resource_information_system_application/models/employee_model.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';

class EmployeeStatsCard extends StatefulWidget {
  final VoidCallback? onTap;

  const EmployeeStatsCard({Key? key, this.onTap}) : super(key: key);

  @override
  _EmployeeStatsCardState createState() => _EmployeeStatsCardState();
}

class _EmployeeStatsCardState extends State<EmployeeStatsCard> {
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final employeeProvider = Provider.of<EmployeeProvider>(
        context,
        listen: false,
      );
      await employeeProvider.loadEmployeeStats();
      // Untuk sekarang kita gunakan data dari employee list
      final stats = {
        'totalEmployees': employeeProvider.employees.length,
        'activeEmployees': employeeProvider.employees
            .where((e) => e.status == 'ACTIVE')
            .length,
        'inactiveEmployees': employeeProvider.employees
            .where((e) => e.status != 'ACTIVE')
            .length,
        'departments': _getDepartmentStats(employeeProvider.employees),
      };
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  List<Map<String, dynamic>> _getDepartmentStats(List<Employee> employees) {
    final departmentMap = <String, int>{};

    for (final employee in employees) {
      final deptName = employee.department?['name'] ?? 'No Department';
      departmentMap[deptName] = (departmentMap[deptName] ?? 0) + 1;
    }

    return departmentMap.entries
        .map((e) => {'name': e.key, 'count': e.value})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_stats == null) {
      return SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Employee Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _loadStats,
                  tooltip: 'Refresh Stats',
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildStatsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _buildStatItem(
          'Total Employees',
          _stats!['totalEmployees'].toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatItem(
          'Active',
          _stats!['activeEmployees'].toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatItem(
          'Inactive',
          _stats!['inactiveEmployees'].toString(),
          Icons.pause_circle,
          Colors.orange,
        ),
        _buildStatItem(
          'Departments',
          _stats!['departments'].length.toString(),
          Icons.business,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

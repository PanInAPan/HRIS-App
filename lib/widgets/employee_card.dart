// lib/features/employees/widgets/employee_card.dart
import 'package:flutter/material.dart';
import '../models/employee_model.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EmployeeCard({
    Key? key,
    required this.employee,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: employee.statusColor.withOpacity(0.2),
          child: Text(
            employee.fullName[0].toUpperCase(),
            style: TextStyle(
              color: employee.statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          employee.fullName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.position ?? 'No position'),
            Text(employee.departmentName),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: employee.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    employee.formattedStatus,
                    style: TextStyle(
                      color: employee.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                if (employee.nip != null)
                  Text(
                    'NIP: ${employee.nip}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
        trailing: _buildTrailingButtons(),
        onTap: onTap,
      ),
    );
  }

  Widget? _buildTrailingButtons() {
    if (onEdit == null && onDelete == null) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
            tooltip: 'Edit Employee',
          ),
        if (onDelete != null)
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
            tooltip: 'Delete Employee',
          ),
      ],
    );
  }
}
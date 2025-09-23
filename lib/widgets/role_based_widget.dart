// lib/widgets/role_based_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RoleBasedWidget extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;

  const RoleBasedWidget({
    required this.child,
    required this.allowedRoles,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (allowedRoles.contains(authProvider.user?.role)) {
      return child;
    } else {
      return SizedBox.shrink(); // atau tampilkan widget kosong
    }
  }
}

// Contoh penggunaan:
/*
RoleBasedWidget(
  allowedRoles: ['ADMIN', 'HR'],
  child: ElevatedButton(
    onPressed: () => print('HR/Admin feature'),
    child: Text('HR/Admin Only'),
  ),
),
*/
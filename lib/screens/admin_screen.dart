// lib/pages/admin_page.dart
import 'package:flutter/material.dart';
import 'package:human_resource_information_system_application/services/auth_service.dart';
import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await ApiService.get('/users');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = (data['data'] as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch users';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserRole(int userId, String newRole) async {
    try {
      final response = await ApiService.patch('/users/$userId/role', {
        'role': newRole,
      });

      if (response.statusCode == 200) {
        // Update local list
        setState(() {
          final index = _users.indexWhere((user) => user.id == userId);
          if (index != -1) {
            _users[index] = User(
              id: _users[index].id,
              email: _users[index].email,
              role: newRole,
              createdAt: _users[index].createdAt,
            );
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role updated successfully')),
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'] ?? 'Update failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating role')),
      );
    }
  }

  Future<void> _showAddUserDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String? selectedRole = 'KARYAWAN';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: ['ADMIN', 'HR', 'KARYAWAN']
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              onChanged: (value) => selectedRole = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                Navigator.pop(context);
                await _addUser(
                  emailController.text,
                  passwordController.text,
                  selectedRole!,
                );
              }
            },
            child: Text('Add User'),
          ),
        ],
      ),
    );
  }

  Future<void> _addUser(String email, String password, String role) async {
    try {
      // final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await AuthService.adminRegister(email, password, role);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User added successfully')),
      );
      
      // Refresh user list
      _fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding user: ${e.toString()}')),
      );
    }
  }

  void _showRoleUpdateDialog(User user) {
    String? selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Role for ${user.email}'),
        content: DropdownButtonFormField<String>(
          value: selectedRole,
          items: ['ADMIN', 'HR', 'KARYAWAN']
              .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
              .toList(),
          onChanged: (value) => selectedRole = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (selectedRole != user.role) {
                _updateUserRole(user.id, selectedRole!);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _users.isEmpty
                  ? Center(child: Text('No users found'))
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(user.email[0].toUpperCase()),
                            ),
                            title: Text(user.email),
                            subtitle: Text('Role: ${user.role}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text(
                                    user.role,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getRoleColor(user.role),
                                ),
                                if (authProvider.user?.id != user.id)
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () =>
                                        _showRoleUpdateDialog(user),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red;
      case 'HR':
        return Colors.blue;
      case 'KARYAWAN':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
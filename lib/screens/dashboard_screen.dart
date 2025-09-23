// lib/pages/main_dashboard.dart
import 'package:flutter/material.dart';
import 'package:human_resource_information_system_application/screens/admin_screen.dart';
import 'package:human_resource_information_system_application/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MainDashboard extends StatefulWidget {
  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardContent(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Tambah admin page jika user adalah admin
    final pages = [..._pages];
    if (authProvider.isAdmin && pages.length < 3) {
      pages.insert(1, AdminPage());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('HRIS App'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          if (authProvider.isAdmin)
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${authProvider.user?.email}!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('Role: ${authProvider.user?.role}'),
          SizedBox(height: 20),
          
          // Statistics Cards
          Row(
            children: [
              _buildStatCard('Users', '50', Icons.people, Colors.blue),
              SizedBox(width: 10),
              _buildStatCard('Tasks', '12', Icons.task, Colors.green),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Quick Actions
          Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (authProvider.isAdmin)
                _buildActionButton('Manage Users', Icons.people, Colors.red),
              if (authProvider.isHR)
                _buildActionButton('HR Tools', Icons.work, Colors.blue),
              _buildActionButton('My Profile', Icons.person, Colors.green),
              _buildActionButton('Settings', Icons.settings, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 40),
              SizedBox(height: 10),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color) {
    return ActionChip(
      avatar: Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
      onPressed: () {
        // Handle action
      },
    );
  }
}
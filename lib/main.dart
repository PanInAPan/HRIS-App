// lib/main.dart - UPDATE DENGAN EMPLOYEE PROVIDER
import 'package:flutter/material.dart';
import 'package:human_resource_information_system_application/providers/employee_provider.dart';
import 'package:human_resource_information_system_application/screens/dashboard_screen.dart';
import 'package:human_resource_information_system_application/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider( // ← GUNAKAN MULTI PROVIDER
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => EmployeeProvider()), // ← TAMBAH INI
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HRIS App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AppLoader(),
      ),
    );
  }
}

class AppLoader extends StatefulWidget {
  @override
  _AppLoaderState createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return authProvider.isAuthenticated ? MainDashboard() : LoginPage();
  }
}
// lib/models/user_model.dart - FIXED VERSION
class User {
  final int id;
  final String email;
  final String role;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory User.fromJson(dynamic json) {
    try {
      final Map<String, dynamic> data = _convertToStringMap(json);
      
      return User(
        id: (data['id'] ?? 0) as int,
        email: (data['email'] ?? '') as String,
        role: (data['role'] ?? 'KARYAWAN') as String,
        createdAt: data['createdAt'] != null 
            ? DateTime.parse(data['createdAt'].toString())
            : null,
      );
    } catch (e) {
      print('❌ Error parsing User: $e');
      return User(
        id: 0,
        email: '',
        role: 'KARYAWAN',
      );
    }
  }

  static Map<String, dynamic> _convertToStringMap(dynamic input) {
    if (input is Map<String, dynamic>) {
      return input;
    } else if (input is Map<dynamic, dynamic>) {
      return input.map((key, value) => MapEntry(key.toString(), value));
    } else {
      return {};
    }
  }
}
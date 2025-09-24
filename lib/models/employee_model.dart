import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Employee {
  final int id;
  final String fullName;
  final String? nip;
  final String? phone;
  final String? address;
  final DateTime? birthDate;
  final String? gender;
  final String? position;
  final DateTime? joinDate;
  final String status;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final Map<String, dynamic> user;
  final Map<String, dynamic>? department;

  Employee({
    required this.id,
    required this.fullName,
    this.nip,
    this.phone,
    this.address,
    this.birthDate,
    this.gender,
    this.position,
    this.joinDate,
    required this.status,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.department,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      fullName: json['fullName'],
      nip: json['nip'],
      phone: json['phone'],
      address: json['address'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      gender: json['gender'],
      position: json['position'],
      joinDate: json['joinDate'] != null ? DateTime.parse(json['joinDate']) : null,
      status: json['status'],
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
      emergencyContactRelation: json['emergencyContactRelation'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] is Map ? json['user'] : {},
      department: json['department'] is Map ? json['department'] : null,
    );
  }

  String get email => user['email'] ?? '';
  String get role => user['role'] ?? 'KARYAWAN';

  String get departmentName => department?['name'] ?? 'No Department';
  
  String get formattedJoinDate {
    if (joinDate == null) return 'Not specified';
    return '${joinDate!.day}/${joinDate!.month}/${joinDate!.year}';
  }

  String get formattedStatus {
    switch (status) {
      case 'ACTIVE': return 'Active';
      case 'RESIGN': return 'Resigned';
      case 'CONTRACT': return 'Contract';
      case 'PROBATION': return 'Probation';
      case 'LEAVE': return 'On Leave';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'ACTIVE': return Colors.green;
      case 'RESIGN': return Colors.red;
      case 'CONTRACT': return Colors.orange;
      case 'PROBATION': return Colors.yellow;
      case 'LEAVE': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
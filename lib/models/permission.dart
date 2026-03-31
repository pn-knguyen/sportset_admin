import 'package:cloud_firestore/cloud_firestore.dart';

class Permission {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> permissions; // Structure: module -> list of actions with enabled status
  final int assignedCount; // Number of staff members with this permission
  final String status; // 'active', 'inactive'
  final DateTime createdAt;
  final DateTime updatedAt;

  Permission({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.assignedCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Permission.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Permission(
      id: snapshot.id,
      name: data?['name'] ?? '',
      description: data?['description'] ?? '',
      permissions: data?['permissions'] ?? {},
      assignedCount: data?['assignedCount'] ?? 0,
      status: data?['status'] ?? 'active',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data?['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'permissions': permissions,
      'assignedCount': assignedCount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

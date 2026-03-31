import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String position; // 'admin', 'manager', 'staff', 'coach', 'receptionist'
  final String facilityId;
  final String facilityName;
  final String status; // 'active', 'inactive', 'suspended'
  final String? avatar;
  final String permissionGroupId; // Reference to permission group
  final DateTime createdAt;
  final DateTime updatedAt;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.facilityId,
    required this.facilityName,
    required this.status,
    this.avatar,
    required this.permissionGroupId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Staff.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Staff(
      id: snapshot.id,
      name: data?['name'] ?? '',
      email: data?['email'] ?? '',
      phone: data?['phone'] ?? '',
      position: data?['position'] ?? 'staff',
      facilityId: data?['facilityId'] ?? '',
      facilityName: data?['facilityName'] ?? '',
      status: data?['status'] ?? 'active',
      avatar: data?['avatar'],
      permissionGroupId: data?['permissionGroupId'] ?? '',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data?['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'facilityId': facilityId,
      'facilityName': facilityName,
      'status': status,
      'avatar': avatar,
      'permissionGroupId': permissionGroupId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

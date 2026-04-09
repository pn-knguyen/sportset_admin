import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String photoUrl;
  final DateTime createdAt;

  const Customer({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.createdAt,
  });

  factory Customer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    final createdAt = ts is Timestamp
        ? ts.toDate()
        : DateTime.now();
    return Customer(
      uid: doc.id,
      fullName: data['fullName'] as String? ?? 'Khách hàng',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  String get initials {
    final parts = fullName.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Facility {
  final String id;
  final String name;
  final String hotline;
  final String address;
  final String openTime;
  final String closeTime;
  final String description;
  final List<String> amenities;
  final String? imageUrl;
  final String status; // 'open' or 'closed'
  final DateTime createdAt;
  final DateTime updatedAt;

  Facility({
    required this.id,
    required this.name,
    required this.hotline,
    required this.address,
    required this.openTime,
    required this.closeTime,
    required this.description,
    required this.amenities,
    this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Facility to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hotline': hotline,
      'address': address,
      'openTime': openTime,
      'closeTime': closeTime,
      'description': description,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create Facility from Firestore document
  factory Facility.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Facility(
      id: doc.id,
      name: data['name'] ?? '',
      hotline: data['hotline'] ?? '',
      address: data['address'] ?? '',
      openTime: data['openTime'] ?? '06:00',
      closeTime: data['closeTime'] ?? '22:00',
      description: data['description'] ?? '',
      amenities: List<String>.from(data['amenities'] ?? []),
      imageUrl: data['imageUrl'],
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create a copy with modified fields
  Facility copyWith({
    String? id,
    String? name,
    String? hotline,
    String? address,
    String? openTime,
    String? closeTime,
    String? description,
    List<String>? amenities,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Facility(
      id: id ?? this.id,
      name: name ?? this.name,
      hotline: hotline ?? this.hotline,
      address: address ?? this.address,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

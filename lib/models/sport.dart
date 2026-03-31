import 'package:cloud_firestore/cloud_firestore.dart';

class Sport {
  final String id;
  final String name;
  final String description;
  final String iconKey;
  final bool isVisible;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Sport({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    required this.isVisible,
    required this.itemCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconKey': iconKey,
      'isVisible': isVisible,
      'itemCount': itemCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Sport.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      return DateTime.now();
    }

    return Sport(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      iconKey: data['iconKey'] as String? ?? 'soccer',
      isVisible: data['isVisible'] as bool? ?? true,
      itemCount: (data['itemCount'] as num?)?.toInt() ?? 0,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }
}

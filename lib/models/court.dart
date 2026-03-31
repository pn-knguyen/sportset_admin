import 'package:cloud_firestore/cloud_firestore.dart';

class Court {
  final String id;
  final String facilityId;
  final String name;
  final String facilityName;
  final String sportType;
  final String address;
  final int pricePerHour;
  final String status;
  final String? imageUrl;
  final String description;
  final List<String> amenities;
  final List<Map<String, dynamic>> subCourts;
  final List<Map<String, dynamic>> weekdayPricing;
  final List<Map<String, dynamic>> weekendPricing;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Court({
    required this.id,
    required this.facilityId,
    required this.name,
    required this.facilityName,
    required this.sportType,
    required this.address,
    required this.pricePerHour,
    required this.status,
    this.imageUrl,
    required this.description,
    required this.amenities,
    required this.subCourts,
    required this.weekdayPricing,
    required this.weekendPricing,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'facilityId': facilityId,
      'name': name,
      'facilityName': facilityName,
      'sportType': sportType,
      'address': address,
      'pricePerHour': pricePerHour,
      'status': status,
      'imageUrl': imageUrl,
      'description': description,
      'amenities': amenities,
      'subCourts': subCourts,
      'weekdayPricing': weekdayPricing,
      'weekendPricing': weekendPricing,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Court.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      return DateTime.now();
    }

    List<Map<String, dynamic>> parseMapList(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return <Map<String, dynamic>>[];
    }

    return Court(
      id: doc.id,
      facilityId:
          data['facilityId'] as String? ??
          data['facilityID'] as String? ??
          data['facility_id'] as String? ??
          '',
      name: data['name'] as String? ?? '',
      facilityName: data['facilityName'] as String? ?? '',
      sportType: data['sportType'] as String? ?? '',
      address: data['address'] as String? ?? '',
      pricePerHour: (data['pricePerHour'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'available',
      imageUrl: data['imageUrl'] as String?,
      description: data['description'] as String? ?? '',
      amenities:
          (data['amenities'] as List?)?.whereType<String>().toList() ??
          <String>[],
      subCourts: parseMapList(data['subCourts']),
      weekdayPricing: parseMapList(data['weekdayPricing']),
      weekendPricing: parseMapList(data['weekendPricing']),
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }
}

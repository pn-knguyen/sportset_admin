import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  final String id;
  final String title;
  final String code;
  final String discountType; // 'percent' or 'fixed'
  final double discountValue;
  final double minOrderValue;
  final int totalQuantity;
  final int usedQuantity;
  final int maxPerUser;
  final bool isActive;
  final String facilityId;
  final String facilityName;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Voucher({
    required this.id,
    required this.title,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.totalQuantity,
    required this.usedQuantity,
    this.maxPerUser = 1,
    required this.isActive,
    required this.facilityId,
    required this.facilityName,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  String get status {
    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return 'upcoming';
    } else if (now.isAfter(endDate)) {
      return 'ended';
    }
    return 'active';
  }

  factory Voucher.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Voucher(
      id: snapshot.id,
      title: data?['title'] ?? '',
      code: data?['code'] ?? '',
      discountType: data?['discountType'] ?? 'percent',
      discountValue: (data?['discountValue'] ?? 0).toDouble(),
      minOrderValue: (data?['minOrderValue'] ?? 0).toDouble(),
      totalQuantity: data?['totalQuantity'] ?? 0,
      usedQuantity: data?['usedQuantity'] ?? 0,
      maxPerUser: data?['maxPerUser'] ?? 1,
      isActive: data?['isActive'] ?? true,
      facilityId: data?['facilityId'] ?? '',
      facilityName: data?['facilityName'] ?? '',
      startDate: (data?['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data?['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data?['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'code': code,
      'discountType': discountType,
      'discountValue': discountValue,
      'minOrderValue': minOrderValue,
      'totalQuantity': totalQuantity,
      'usedQuantity': usedQuantity,
      'maxPerUser': maxPerUser,
      'isActive': isActive,
      'facilityId': facilityId,
      'facilityName': facilityName,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

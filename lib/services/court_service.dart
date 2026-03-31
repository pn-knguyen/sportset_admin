import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportset_admin/models/court.dart';

class CourtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'courts';

  Stream<List<Court>> getAllCourtsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Court.fromFirestore(doc)).toList(),
        );
  }

  Future<Court?> getCourtById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return Court.fromFirestore(doc);
  }

  Stream<Court?> getCourtByIdStream(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return Court.fromFirestore(doc);
    });
  }

  Future<String> createCourt({
    required String facilityId,
    required String name,
    required String facilityName,
    required String sportType,
    required String address,
    required int pricePerHour,
    required String status,
    String? imageUrl,
    required String description,
    required List<String> amenities,
    required List<Map<String, dynamic>> subCourts,
    required List<Map<String, dynamic>> weekdayPricing,
    required List<Map<String, dynamic>> weekendPricing,
  }) async {
    final now = DateTime.now();
    final docRef = await _firestore.collection(_collection).add({
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
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return docRef.id;
  }

  Future<void> updateCourt({
    required String id,
    required String facilityId,
    required String name,
    required String facilityName,
    required String sportType,
    required String address,
    required int pricePerHour,
    required String status,
    String? imageUrl,
    required String description,
    required List<String> amenities,
    required List<Map<String, dynamic>> subCourts,
    required List<Map<String, dynamic>> weekdayPricing,
    required List<Map<String, dynamic>> weekendPricing,
  }) async {
    await _firestore.collection(_collection).doc(id).update({
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
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteCourt(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Stream<List<Court>> getCourtsByFacilityIdStream(String facilityId) {
    return _firestore
        .collection(_collection)
        .where('facilityId', isEqualTo: facilityId)
        .snapshots()
        .map((snapshot) {
          final courts = snapshot.docs
              .map((doc) => Court.fromFirestore(doc))
              .toList();

          courts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return courts;
        });
  }
}

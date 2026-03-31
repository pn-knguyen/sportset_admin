import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportset_admin/models/facility.dart';

class FacilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'facilities';

  // Create a new facility
  Future<String> createFacility({
    required String name,
    required String hotline,
    required String address,
    required String openTime,
    required String closeTime,
    required String description,
    required List<String> amenities,
    String? imageUrl,
    String status = 'open',
  }) async {
    final now = DateTime.now();
    final docRef = await _firestore.collection(_collection).add({
      'name': name,
      'hotline': hotline,
      'address': address,
      'openTime': openTime,
      'closeTime': closeTime,
      'description': description,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return docRef.id;
  }

  // Get all facilities as a stream
  Stream<List<Facility>> getAllFacilitiesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Facility.fromFirestore(doc))
              .toList();
        });
  }

  // Get all facilities (one-time fetch)
  Future<List<Facility>> getAllFacilities() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Facility.fromFirestore(doc)).toList();
  }

  // Get a single facility by ID
  Future<Facility?> getFacilityById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Facility.fromFirestore(doc);
    }
    return null;
  }

  // Get facility by ID as stream
  Stream<Facility?> getFacilityByIdStream(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return Facility.fromFirestore(doc);
      }
      return null;
    });
  }

  // Update a facility
  Future<void> updateFacility({
    required String id,
    required String name,
    required String hotline,
    required String address,
    required String openTime,
    required String closeTime,
    required String description,
    required List<String> amenities,
    String? imageUrl,
    String? status,
  }) async {
    await _firestore.collection(_collection).doc(id).update({
      'name': name,
      'hotline': hotline,
      'address': address,
      'openTime': openTime,
      'closeTime': closeTime,
      'description': description,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'status': status,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Delete a facility
  Future<void> deleteFacility(String id) async {
    final courtCount = await getCourtCountByFacility(id);
    if (courtCount > 0) {
      throw StateError(
        'Không thể xóa cơ sở vì vẫn còn $courtCount sân trực thuộc.',
      );
    }

    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<int> getCourtCountByFacility(String facilityId) async {
    final snapshot = await _firestore
        .collection('courts')
        .where('facilityId', isEqualTo: facilityId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  // Search facilities by name
  Future<List<Facility>> searchFacilities(String query) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();
    return snapshot.docs.map((doc) => Facility.fromFirestore(doc)).toList();
  }

  // Get facilities by status
  Stream<List<Facility>> getFacilitiesByStatusStream(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Facility.fromFirestore(doc))
              .toList();
        });
  }
}

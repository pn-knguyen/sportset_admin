import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportset_admin/models/staff.dart';

class StaffService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'staff';

  // Create new staff member
  Future<String> createStaff(Staff staff) async {
    try {
      final docRef = await _db.collection(_collectionName).add(staff.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create staff: $e');
    }
  }

  // Get all staff as stream
  Stream<List<Staff>> getAllStaffStream() {
    return _db
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Staff.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    });
  }

  // Get all staff as future
  Future<List<Staff>> getAllStaffFuture() async {
    try {
      final snapshot = await _db
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Staff.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    } catch (e) {
      throw Exception('Failed to get staff: $e');
    }
  }

  // Get staff by ID as stream
  Stream<Staff?> getStaffByIdStream(String staffId) {
    return _db.collection(_collectionName).doc(staffId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Staff.fromFirestore(snapshot, null);
    });
  }

  // Get staff by ID as future
  Future<Staff?> getStaffByIdFuture(String staffId) async {
    try {
      final snapshot = await _db.collection(_collectionName).doc(staffId).get();
      if (!snapshot.exists) {
        return null;
      }
      return Staff.fromFirestore(snapshot, null);
    } catch (e) {
      throw Exception('Failed to get staff: $e');
    }
  }

  // Update staff
  Future<void> updateStaff(String staffId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _db.collection(_collectionName).doc(staffId).update(data);
    } catch (e) {
      throw Exception('Failed to update staff: $e');
    }
  }

  // Delete staff
  Future<void> deleteStaff(String staffId) async {
    try {
      await _db.collection(_collectionName).doc(staffId).delete();
    } catch (e) {
      throw Exception('Failed to delete staff: $e');
    }
  }

  // Get staff by facility
  Stream<List<Staff>> getStaffByFacilityStream(String facilityId) {
    return _db
        .collection(_collectionName)
        .where('facilityId', isEqualTo: facilityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Staff.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    });
  }

  // Get staff by permission group
  Stream<List<Staff>> getStaffByPermissionGroupStream(String permissionGroupId) {
    return _db
        .collection(_collectionName)
        .where('permissionGroupId', isEqualTo: permissionGroupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Staff.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    });
  }

  // Get staff by status
  Stream<List<Staff>> getStaffByStatusStream(String status) {
    return _db
        .collection(_collectionName)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Staff.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    });
  }

  // Search staff by name or email
  Future<List<Staff>> searchStaff(String query) async {
    try {
      final snapshot = await _db
          .collection(_collectionName)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();
      return snapshot.docs
          .map((doc) => Staff.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    } catch (e) {
      throw Exception('Failed to search staff: $e');
    }
  }

  // Get staff count by facility
  Future<int> getStaffCountByFacility(String facilityId) async {
    try {
      final snapshot = await _db
          .collection(_collectionName)
          .where('facilityId', isEqualTo: facilityId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get staff count: $e');
    }
  }
}

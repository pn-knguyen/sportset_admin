import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportset_admin/models/permission.dart';

class PermissionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'permissions';
  final String _staffCollectionName = 'staff';

  // Create new permission group
  Future<String> createPermission(Permission permission) async {
    try {
      final docRef = await _db.collection(_collectionName).add(permission.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create permission: $e');
    }
  }

  // Get all permissions as stream
  Stream<List<Permission>> getAllPermissionsStream() {
    return _db
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Permission.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    });
  }

  // Get all permissions as future
  Future<List<Permission>> getAllPermissionsFuture() async {
    try {
      final snapshot = await _db
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Permission.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    } catch (e) {
      throw Exception('Failed to get permissions: $e');
    }
  }

  // Get permission by ID as stream
  Stream<Permission?> getPermissionByIdStream(String permissionId) {
    return _db.collection(_collectionName).doc(permissionId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Permission.fromFirestore(snapshot, null);
    });
  }

  // Get permission by ID as future
  Future<Permission?> getPermissionByIdFuture(String permissionId) async {
    try {
      final snapshot = await _db.collection(_collectionName).doc(permissionId).get();
      if (!snapshot.exists) {
        return null;
      }
      return Permission.fromFirestore(snapshot, null);
    } catch (e) {
      throw Exception('Failed to get permission: $e');
    }
  }

  // Update permission
  Future<void> updatePermission(String permissionId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _db.collection(_collectionName).doc(permissionId).update(data);
    } catch (e) {
      throw Exception('Failed to update permission: $e');
    }
  }

  // Delete permission
  Future<void> deletePermission(String permissionId) async {
    try {
      await _db.collection(_collectionName).doc(permissionId).delete();
    } catch (e) {
      throw Exception('Failed to delete permission: $e');
    }
  }

  // Get permissions by status
  Stream<List<Permission>> getPermissionsByStatusStream(String status) {
    return _db
        .collection(_collectionName)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Permission.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    });
  }

  // Search permission by name
  Future<List<Permission>> searchPermission(String query) async {
    try {
      final snapshot = await _db
          .collection(_collectionName)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();
      return snapshot.docs
          .map((doc) => Permission.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    } catch (e) {
      throw Exception('Failed to search permission: $e');
    }
  }

  // Get assigned staff count for a permission group
  Future<int> getAssignedStaffCount(String permissionId) async {
    try {
      final snapshot = await _db
          .collection(_staffCollectionName)
          .where('permissionGroupId', isEqualTo: permissionId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get assigned staff count: $e');
    }
  }

  // Update assigned count and status for permission
  Future<void> updatePermissionAssignedCount(String permissionId) async {
    try {
      final count = await getAssignedStaffCount(permissionId);
      final status = count > 0 ? 'active' : 'inactive';
      await _db.collection(_collectionName).doc(permissionId).update({
        'assignedCount': count,
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update permission assigned count: $e');
    }
  }

  // Get staff count by permission
  Stream<Map<String, int>> getStaffCountByPermissionStream() {
    return _db.collection(_staffCollectionName).snapshots().map((snapshot) {
      final counts = <String, int>{};
      for (var doc in snapshot.docs) {
        final staffData = doc.data();
        final permissionGroupId = staffData['permissionGroupId'] as String?;
        if (permissionGroupId != null) {
          counts[permissionGroupId] = (counts[permissionGroupId] ?? 0) + 1;
        }
      }
      return counts;
    });
  }

  // Get default permissions template
  static Map<String, dynamic> getDefaultPermissionsTemplate() {
    return {
      'facilities': {
        'view': false,
        'create': false,
        'update': false,
        'delete': false,
      },
      'courts': {
        'view': false,
        'create': false,
        'update': false,
        'delete': false,
      },
      'bookings': {
        'view': false,
        'approve': false,
        'cancel': false,
        'check_in': false,
      },
      'vouchers': {
        'view': false,
        'create': false,
        'update': false,
        'delete': false,
      },
      'staff': {
        'view': false,
        'create': false,
        'update': false,
        'delete': false,
        'assign_permissions': false,
      },
      'accounts': {
        'view': false,
        'create': false,
        'update': false,
        'delete': false,
      },
      'sports': {
        'view': false,
        'create': false,
        'update': false,
        'delete': false,
      },
      'reports': {
        'view': false,
        'export': false,
      },
      'settings': {
        'view': false,
        'update': false,
      },
    };
  }
}

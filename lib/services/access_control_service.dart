import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccessControlService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getCurrentPermissionMap() async {
    final user = _auth.currentUser;
    if (user == null) {
      return <String, dynamic>{};
    }

    final accountDoc =
        await _firestore.collection('admin_accounts').doc(user.uid).get();
    if (!accountDoc.exists) {
      return <String, dynamic>{};
    }

    final permissionGroupId =
        (accountDoc.data()?['permissionGroupId'] as String?)?.trim();
    if (permissionGroupId == null || permissionGroupId.isEmpty) {
      return <String, dynamic>{};
    }

    final permissionDoc =
        await _firestore.collection('permissions').doc(permissionGroupId).get();
    if (!permissionDoc.exists) {
      return <String, dynamic>{};
    }

    final permissions = permissionDoc.data()?['permissions'];
    if (permissions is Map<String, dynamic>) {
      return permissions;
    }

    return <String, dynamic>{};
  }

  Future<bool> canManagePermissionGroupsForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    final accountDoc =
        await _firestore.collection('admin_accounts').doc(user.uid).get();
    if (!accountDoc.exists) {
      return false;
    }

    final accountData = accountDoc.data() ?? <String, dynamic>{};

    final permissionGroupId =
        (accountData['permissionGroupId'] as String?)?.trim();
    if (permissionGroupId == null || permissionGroupId.isEmpty) {
      return false;
    }

    final permissionDoc =
        await _firestore.collection('permissions').doc(permissionGroupId).get();
    if (!permissionDoc.exists) {
      return false;
    }

    final permissionData = permissionDoc.data() ?? <String, dynamic>{};
    final permissions = permissionData['permissions'];
    if (permissions is! Map<String, dynamic>) {
      return false;
    }

    return can(permissions, 'staff', 'assign_permissions') ||
        _hasFullAccess(permissions);
  }

  bool can(
    Map<String, dynamic> permissionMap,
    String module,
    String action,
  ) {
    final moduleData = permissionMap[module];
    if (moduleData is! Map<String, dynamic>) {
      return false;
    }

    final value = moduleData[action];
    return value is bool ? value : false;
  }

  bool _hasFullAccess(Map<String, dynamic> permissions) {
    for (final moduleEntry in permissions.entries) {
      final actionMap = moduleEntry.value;
      if (actionMap is! Map<String, dynamic>) {
        return false;
      }

      for (final actionEntry in actionMap.entries) {
        if (actionEntry.value != true) {
          return false;
        }
      }
    }

    return true;
  }
}

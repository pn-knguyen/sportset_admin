import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sportset_admin/services/permission_service.dart';

class SetupService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final PermissionService _permissionService = PermissionService();

  /// Setup default admin account and admin permission group
  static Future<Map<String, dynamic>> setupDefaultAdmin() async {
    try {
      print('[SetupService] 🚀 Bắt đầu setup admin account...');
      const adminEmail = 'admin@sportset.local';
      const adminPassword = 'admin123456';

      // Check if admin permission group already exists
      final adminPermQuery = await _firestore
          .collection('permissions')
          .where('name', isEqualTo: 'Admin')
          .limit(1)
          .get();

      print('[SetupService] 📋 Kiểm tra permission group Admin: ${adminPermQuery.docs.length} found');

      String adminPermissionGroupId = '';

      if (adminPermQuery.docs.isEmpty) {
        // Create admin permission group with all permissions enabled
        final defaultPermissions =
            PermissionService.getDefaultPermissionsTemplate();

        // Enable all permissions
        defaultPermissions.forEach((module, actions) {
          if (actions is Map<String, dynamic>) {
            actions.forEach((action, _) {
              actions[action] = true;
            });
          }
        });

        final adminPermDoc = await _firestore.collection('permissions').add({
          'name': 'Admin',
          'description': 'Nhóm quyền quản trị viên - toàn quyền hệ thống',
          'permissions': defaultPermissions,
          'assignedCount': 0,
          'status': 'active',
          'isProtected': true, // Flag for protection
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        adminPermissionGroupId = adminPermDoc.id;
        print('[SetupService] ✅ Tạo permission group Admin: $adminPermissionGroupId');
      } else {
        adminPermissionGroupId = adminPermQuery.docs.first.id;
        print('[SetupService] ℹ️  Permission group Admin đã tồn tại: $adminPermissionGroupId');
      }

      // Check if admin account already exists in Firestore
      final adminUserQuery = await _firestore
          .collection('admin_accounts')
          .where('username', isEqualTo: 'admin')
          .limit(1)
          .get();

      print('[SetupService] 📋 Kiểm tra admin account: ${adminUserQuery.docs.length} found');

      if (adminUserQuery.docs.isEmpty) {
        // Try to sign in with existing Firebase Auth user first
        String uid = '';
        
        try {
          // Try to create new Firebase Auth user
          UserCredential userCredential =
              await _firebaseAuth.createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );
          uid = userCredential.user!.uid;
          print('[SetupService] ✅ Tạo Firebase Auth user: $adminEmail (uid: $uid)');
        } catch (e) {
          if (e.toString().contains('email-already-in-use')) {
            // Email already exists, try to find the user
            print('[SetupService] ℹ️  Email $adminEmail đã tồn tại, kiểm tra lại...');
            
            // Try to sign in to get the user
            try {
              UserCredential signInResult = await _firebaseAuth.signInWithEmailAndPassword(
                email: adminEmail,
                password: adminPassword,
              );
              uid = signInResult.user!.uid;
              print('[SetupService] ✅ Firebase Auth user tồn tại: $adminEmail (uid: $uid)');
              
              // Sign out immediately after getting the UID
              await _firebaseAuth.signOut();
            } catch (signInError) {
              print('[SetupService] ⚠️  Không thể sign in: $signInError');
              return {
                'success': false,
                'message': 'Firebase Auth user đã tồn tại nhưng password không đúng: $signInError',
                'error': signInError.toString(),
              };
            }
          } else {
            rethrow;
          }
        }

        final now = FieldValue.serverTimestamp();

        // Create admin_accounts document
        await _firestore.collection('admin_accounts').doc(uid).set({
          'uid': uid,
          'username': 'admin',
          'authEmail': adminEmail,
          'permissionGroupId': adminPermissionGroupId,
          'isActive': true,
          'isProtected': true, // Flag for protection
          'createdAt': now,
          'updatedAt': now,
        });

        print('[SetupService] ✅ Tạo Firestore doc admin_accounts/$uid');

        // Create users document
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'username': 'admin',
          'email': adminEmail,
          'status': 'active',
          'createdAt': now,
          'updatedAt': now,
        });

        print('[SetupService] ✅ Tạo Firestore doc users/$uid');

        return {
          'success': true,
          'message': 'Admin user created successfully',
          'email': adminEmail,
          'password': adminPassword,
          'uid': uid,
        };
      } else {
        print('[SetupService] ℹ️  Admin account đã tồn tại');
        return {
          'success': true,
          'message': 'Admin user already exists',
          'email': adminEmail,
        };
      }
    } catch (e) {
      print('[SetupService] ❌ LỖI: $e');
      return {
        'success': false,
        'message': 'Error setting up admin: $e',
        'error': e.toString(),
      };
    }
  }

  /// Check if permission group is admin (protected)
  static bool isAdminPermissionGroup(String permissionGroupId) {
    // This would need to be checked against the permission document
    // For now, we'll rely on the 'isProtected' flag in Firestore
    return false; // Will be overridden in UI
  }

  /// Check if account is admin (protected)
  static bool isAdminAccount(String uid) {
    // This would need to be checked against the admin_accounts document
    // For now, we'll rely on the 'isProtected' flag in Firestore
    return false; // Will be overridden in UI
  }

  /// Debug: Show all accounts in Firestore
  static Future<void> debugShowAllAccounts() async {
    try {
      print('[SetupService] 🔍 DEBUG: Tất cả tài khoản trong admin_accounts:');
      final adminAccounts = await _firestore.collection('admin_accounts').get();
      
      if (adminAccounts.docs.isEmpty) {
        print('[SetupService] ⚠️  Không có tài khoản nào');
      } else {
        for (var doc in adminAccounts.docs) {
          final data = doc.data();
          print('[SetupService] 📋 - uid: ${doc.id}, username: ${data['username']}, email: ${data['authEmail']}, isProtected: ${data['isProtected']}');
        }
      }
      
      print('[SetupService] 🔍 DEBUG: Tất cả permission groups:');
      final permissions = await _firestore.collection('permissions').get();
      
      if (permissions.docs.isEmpty) {
        print('[SetupService] ⚠️  Không có permission group nào');
      } else {
        for (var doc in permissions.docs) {
          final data = doc.data();
          print('[SetupService] 📋 - id: ${doc.id}, name: ${data['name']}, isProtected: ${data['isProtected']}');
        }
      }
    } catch (e) {
      print('[SetupService] ❌ Debug error: $e');
    }
  }

  /// Clean up: Try to delete a Firebase Auth user by attempting sign in and delete
  /// This is a workaround when user creation fails but Firebase keeps the email
  static Future<Map<String, dynamic>> cleanupFailedFirebaseUser(
    String email,
    String password,
  ) async {
    try {
      print('[SetupService] 🧹 Attempting to clean up failed user: $email');
      
      // Try to sign in
      UserCredential signInResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = signInResult.user;
      if (user != null) {
        // Delete the user
        await user.delete();
        print('[SetupService] ✅ Xóa Firebase user thành công: $email');
        return {
          'success': true,
          'message': 'Đã xóa user $email khỏi Firebase',
        };
      } else {
        return {
          'success': false,
          'message': 'Không tìm thấy user $email',
        };
      }
    } catch (e) {
      print('[SetupService] ❌ Cleanup error: $e');
      return {
        'success': false,
        'message': 'Lỗi khi xóa user: $e',
        'error': e.toString(),
      };
    }
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportset_admin/models/permission.dart';
import 'package:sportset_admin/models/staff.dart';
import 'package:sportset_admin/services/permission_service.dart';
import 'package:sportset_admin/services/staff_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final StaffService _staffService = StaffService();
  final PermissionService _permissionService = PermissionService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AccessControlService _accessControlService = AccessControlService();

  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  final Color _secondaryColor = const Color(0xFFFF4E00);

  String? _selectedStaffId;
  String? _selectedPermissionGroupId;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _checkCreatePermission();
  }
  
  Future<void> _checkCreatePermission() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    final hasPermission = _accessControlService.can(permissionMap, 'accounts', 'create');
    
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bạn không có quyền tạo tài khoản'),
          backgroundColor: _orangeColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 32),
                  _buildFormFields(),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF0C1C46),
                  size: 20,
                ),
              ),
              const Expanded(
                child: Text(
                  'Tạo tài khoản',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0C1C46),
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _orangeColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add,
            size: 40,
            color: _orangeColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tạo Tài Khoản Mới',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _navyColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Chọn nhân viên và thiết lập thông tin đăng nhập',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildStaffSelector(),
        const SizedBox(height: 20),
        _buildPermissionSelector(),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Tên đăng nhập',
          controller: _usernameController,
          icon: Icons.person_outline,
          placeholder: 'ten_dang_nhap',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20),
        _buildPasswordField(
          label: 'Mật khẩu',
          controller: _passwordController,
          obscure: _obscurePassword,
          onToggle: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        const SizedBox(height: 20),
        _buildPasswordField(
          label: 'Xác nhận mật khẩu',
          controller: _confirmPasswordController,
          obscure: _obscureConfirmPassword,
          onToggle: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
        ),
      ],
    );
  }

  Widget _buildStaffSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Chọn Nhân Viên',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _navyColor,
            ),
          ),
        ),
        StreamBuilder<List<Staff>>(
          stream: _staffService.getAllStaffStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                    ),
                  ],
                ),
                height: 56,
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: _orangeColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: const Text('Lỗi tải dữ liệu'),
              );
            }

            final staffList = snapshot.data ?? [];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedStaffId,
                isExpanded: true,
                menuMaxHeight: 320,
                decoration: InputDecoration(
                  hintText: 'Chọn nhân viên',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                icon: Icon(
                  Icons.expand_more,
                  color: Colors.grey[400],
                ),
                style: TextStyle(fontSize: 14, color: _navyColor),
                dropdownColor: Colors.white,
                items: staffList.map((staff) {
                  return DropdownMenuItem<String>(
                    value: staff.id,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '${staff.name} (${staff.email})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (context) {
                  return staffList.map((staff) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        staff.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                onChanged: (value) {
                  setState(() {
                    _selectedStaffId = value;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String placeholder,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _navyColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.grey[400],
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Nhóm Quyền Cho Tài Khoản',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _navyColor,
            ),
          ),
        ),
        StreamBuilder<List<Permission>>(
          stream: _permissionService.getAllPermissionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                    ),
                  ],
                ),
                height: 56,
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: _orangeColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: const Text('Lỗi tải nhóm quyền'),
              );
            }

            final permissions = snapshot.data ?? [];
            if (permissions.isEmpty) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: const Text('Chưa có nhóm quyền. Hãy tạo nhóm quyền trước.'),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedPermissionGroupId,
                isExpanded: true,
                menuMaxHeight: 320,
                decoration: InputDecoration(
                  hintText: 'Chọn nhóm quyền',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                icon: Icon(
                  Icons.expand_more,
                  color: Colors.grey[400],
                ),
                style: TextStyle(fontSize: 14, color: _navyColor),
                dropdownColor: Colors.white,
                items: permissions.map((permission) {
                  return DropdownMenuItem<String>(
                    value: permission.id,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        permission.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPermissionGroupId = value;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _navyColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.grey[400],
                size: 20,
              ),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orangeColor, _secondaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _orangeColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreateAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Tạo Tài Khoản',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _handleCreateAccount() async {
    if (_selectedStaffId == null ||
        _selectedPermissionGroupId == null ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu xác nhận không khớp'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu phải ít nhất 6 ký tự'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final authEmail = _buildAuthEmailFromUsername(username);

      // Get staff info
      final staffDoc =
          await _firestore.collection('staff').doc(_selectedStaffId).get();
      final staff = Staff.fromFirestore(staffDoc, null);

      // Check if Firestore doc already exists
      final existingDoc = await _firestore
          .collection('admin_accounts')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (existingDoc.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tên đăng nhập đã tồn tại'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Try to create Firebase Auth user
      late UserCredential userCredential;
      try {
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: authEmail,
          password: _passwordController.text,
        );
      } on FirebaseAuthException catch (authError) {
        if (authError.code == 'email-already-in-use') {
          // Firebase user exists but Firestore doc doesn't - try to recover
          print('[AccountCreation] ⚠️  Email already exists, checking if we need cleanup...');
          
          // Try to sign in and see if we can delete it
          try {
            final existingUser = await _firebaseAuth.signInWithEmailAndPassword(
              email: authEmail,
              password: _passwordController.text,
            );
            
            // If sign in works with given password, delete the orphan user
            await existingUser.user?.delete();
            print('[AccountCreation] ✅ Deleted orphan Firebase user: $authEmail');
            
            // Try again
            userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
              email: authEmail,
              password: _passwordController.text,
            );
            
            // Sign out after delete
            await _firebaseAuth.signOut();
          } catch (signInError) {
            print('[AccountCreation] ⚠️  Cannot auto-cleanup (password mismatch): $signInError');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email đã được sử dụng. Vui lòng dùng email khác hoặc liên hệ admin.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
            }
            return;
          }
        } else {
          rethrow;
        }
      }

      final uid = userCredential.user!.uid;
      
      try {
        // Save user info to Firestore
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'username': username,
          'email': authEmail,
          'staffId': _selectedStaffId,
          'staffName': staff.name,
          'permissionGroupId': _selectedPermissionGroupId,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });

        // Separate collection for admin sign-in authorization.
        await _firestore
            .collection('admin_accounts')
            .doc(uid)
            .set({
          'uid': uid,
          'username': username,
          'authEmail': authEmail,
          'staffId': _selectedStaffId,
          'staffName': staff.name,
          'permissionGroupId': _selectedPermissionGroupId,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tạo tài khoản cho "${staff.name}" thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (firestoreError) {
        // Rollback: Delete Firebase Auth user if Firestore save fails
        print('[AccountCreation] ⚠️  Firestore error: $firestoreError, rolling back Firebase user...');
        
        try {
          await userCredential.user?.delete();
          print('[AccountCreation] ✅ Rolled back Firebase user $uid');
        } catch (deleteError) {
          print('[AccountCreation] ❌ Failed to rollback Firebase user: $deleteError');
        }
        
        rethrow; // Rethrow to show error message
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final errorMessage = _mapFirebaseAuthError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _buildAuthEmailFromUsername(String username) {
    final normalized = username
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9._-]'), '');

    if (normalized.isEmpty) {
      throw const FormatException('Tên đăng nhập không hợp lệ');
    }

    return '$normalized@sportset.local';
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    if (e.code == 'email-already-in-use') {
      return 'Tên đăng nhập đã tồn tại';
    }

    if (e.code == 'weak-password') {
      return 'Mật khẩu quá yếu';
    }

    if (e.code == 'invalid-email') {
      return 'Tên đăng nhập không hợp lệ';
    }

    final rawMessage = (e.message ?? '').toUpperCase();
    if (e.code == 'internal-error' &&
        rawMessage.contains('CONFIGURATION_NOT_FOUND')) {
      return 'Firebase Auth chưa cấu hình App Verification (reCAPTCHA/Play Integrity). Vui lòng cấu hình trong Firebase Console rồi thử lại.';
    }

    return 'Lỗi tạo tài khoản: ${e.code}';
  }
}

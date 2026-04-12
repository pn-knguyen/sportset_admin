import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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

  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _secondary = Color(0xFF18A5A7);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);

  String? _selectedStaffId;
  String? _selectedPermissionGroupId;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _avatarFile;
  bool _isUploadingAvatar = false;
  final ImagePicker _imagePicker = ImagePicker();

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
        const SnackBar(
          content: Text('Bạn không có quyền tạo tài khoản'),
          backgroundColor: _primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null && mounted) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  Future<String?> _uploadAvatarToStorage(String uid) async {
    if (_avatarFile == null) return null;
    setState(() => _isUploadingAvatar = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars/$uid.jpg');
      await ref.putFile(_avatarFile!);
      return await ref.getDownloadURL();
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
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
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_lightGreen, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: _darkGreen,
                        size: 20,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Thêm tài khoản',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 24),
                  _buildStaffSelector(),
                  const SizedBox(height: 20),
                  _buildPermissionSelector(),
                  const SizedBox(height: 20),
                  _buildInput(
                    label: 'Tên đăng nhập',
                    controller: _usernameController,
                    icon: Icons.account_circle,
                    hintText: 'Ví dụ: nva_arena',
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    label: 'Mật khẩu',
                    controller: _passwordController,
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    hint: 'Tối thiểu 8 ký tự, bao gồm chữ và số',
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    label: 'Xác nhận mật khẩu',
                    controller: _confirmPasswordController,
                    obscure: _obscureConfirmPassword,
                    onToggle: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _avatarFile != null
                      ? Image.file(
                          _avatarFile!,
                          fit: BoxFit.cover,
                          width: 128,
                          height: 128,
                        )
                      : const Icon(
                          Icons.person,
                          size: 48,
                          color: Color(0xFFBECAB9),
                        ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isUploadingAvatar
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _avatarFile != null ? Icons.edit : Icons.add_a_photo,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Text(
            _avatarFile != null ? 'ĐỔI ẢNH ĐẠI DIỆN' : 'TẢI LÊN ẢNH ĐẠI DIỆN',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
        ),
        if (_avatarFile != null) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _avatarFile = null),
            child: Text(
              'Xóa ảnh',
              style: TextStyle(
                fontSize: 11,
                color: Colors.red.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _onSurface,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: _onSurfaceVariant.withValues(alpha: 0.5),
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(icon, color: _secondary, size: 22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: _primary.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildStaffSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHỌN NHÂN VIÊN',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Staff>>(
          stream: _staffService.getAllStaffStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24)],
                ),
                height: 56,
                child: const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: _primary, strokeWidth: 2),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(16),
                child: const Text('Lỗi tải dữ liệu'),
              );
            }
            final staffList = snapshot.data ?? [];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24)],
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedStaffId,
                isExpanded: true,
                menuMaxHeight: 320,
                decoration: InputDecoration(
                  hintText: 'Chọn nhân viên từ danh sách',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: _onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  prefixIcon: const Icon(Icons.badge, color: _secondary, size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                icon: const Icon(Icons.expand_more, color: Color(0xFFBECAB9)),
                style: const TextStyle(fontSize: 14, color: _onSurface),
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
                      child: Text(staff.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  }).toList();
                },
                onChanged: (value) => setState(() => _selectedStaffId = value),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPermissionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHỌN NHÓM QUYỀN',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Permission>>(
          stream: _permissionService.getAllPermissionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24)],
                ),
                height: 56,
                child: const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: _primary, strokeWidth: 2),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(16),
                child: const Text('Lỗi tải nhóm quyền'),
              );
            }
            final permissions = snapshot.data ?? [];
            if (permissions.isEmpty) {
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(16),
                child: const Text('Chưa có nhóm quyền. Hãy tạo nhóm quyền trước.'),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24)],
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedPermissionGroupId,
                isExpanded: true,
                menuMaxHeight: 320,
                decoration: InputDecoration(
                  hintText: 'Chọn nhóm quyền',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: _onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  prefixIcon: const Icon(Icons.work, color: _secondary, size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                icon: const Icon(Icons.expand_more, color: Color(0xFFBECAB9)),
                style: const TextStyle(fontSize: 14, color: _onSurface),
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
                onChanged: (value) =>
                    setState(() => _selectedPermissionGroupId = value),
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
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(
                fontSize: 14,
                color: _onSurfaceVariant.withValues(alpha: 0.5),
              ),
              prefixIcon: const Icon(Icons.lock, color: _secondary, size: 22),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFFBECAB9),
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: _primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(fontSize: 14, color: _onSurface),
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 11,
                color: _onSurfaceVariant.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.check_circle, color: Colors.white),
        label: _isLoading
            ? const SizedBox.shrink()
            : const Text(
                'Tạo tài khoản',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary.withValues(alpha: 0.6),
          shadowColor: _primary.withValues(alpha: 0.3),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: _isLoading ? null : _handleCreateAccount,
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
          debugPrint('[AccountCreation] ⚠️  Email already exists, checking if we need cleanup...');
          
          // Try to sign in and see if we can delete it
          try {
            final existingUser = await _firebaseAuth.signInWithEmailAndPassword(
              email: authEmail,
              password: _passwordController.text,
            );
            
            // If sign in works with given password, delete the orphan user
            await existingUser.user?.delete();
            debugPrint('[AccountCreation] ✅ Deleted orphan Firebase user: $authEmail');
            
            // Try again
            userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
              email: authEmail,
              password: _passwordController.text,
            );
            
            // Sign out after delete
            await _firebaseAuth.signOut();
          } catch (signInError) {
            debugPrint('[AccountCreation] ⚠️  Cannot auto-cleanup (password mismatch): $signInError');
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

      // Upload avatar if selected
      final avatarUrl = await _uploadAvatarToStorage(uid);

      try {
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
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
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
        debugPrint('[AccountCreation] ⚠️  Firestore error: $firestoreError, rolling back Firebase user...');
        
        try {
          await userCredential.user?.delete();
          debugPrint('[AccountCreation] ✅ Rolled back Firebase user $uid');
        } catch (deleteError) {
          debugPrint('[AccountCreation] ❌ Failed to rollback Firebase user: $deleteError');
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

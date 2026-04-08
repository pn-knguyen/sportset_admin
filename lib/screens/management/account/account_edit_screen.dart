import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class AccountEditScreen extends StatefulWidget {
  const AccountEditScreen({super.key});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();

  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _secondary = Color(0xFF18A5A7);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);

  String? _uid;
  String? _selectedPermissionGroupId;
  String? _selectedStaffId;
  String? _avatarUrl;
  File? _avatarFile;
  bool _isUploadingAvatar = false;
  bool _isActive = true;
  bool _isLoading = false;
  bool _initialized = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _permissionDocs = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _staffDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _uid = args?['uid'] as String?;
    _initialized = true;

    if (_uid == null || _uid!.isEmpty) {
      return;
    }

    _loadData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_uid == null) return;
    setState(() => _isLoading = true);
    try {
      final permissionSnapshot =
          await _firestore.collection('permissions').orderBy('createdAt').get();
      final staffSnapshot =
          await _firestore.collection('staff').orderBy('name').get();
      final accountDoc =
          await _firestore.collection('admin_accounts').doc(_uid).get();

      if (!accountDoc.exists || !mounted) return;

      final data = accountDoc.data() ?? <String, dynamic>{};
      setState(() {
        _permissionDocs = permissionSnapshot.docs;
        _staffDocs = staffSnapshot.docs;
        _usernameController.text = (data['username'] ?? '') as String;
        _selectedPermissionGroupId = data['permissionGroupId'] as String?;
        _selectedStaffId = data['staffId'] as String?;
        _avatarUrl = data['avatarUrl'] as String?;
        _isActive = data['isActive'] == true;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      final ref = FirebaseStorage.instance.ref().child('avatars/$uid.jpg');
      await ref.putFile(_avatarFile!);
      return await ref.getDownloadURL();
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _handleSave() async {
    if (_uid == null) return;

    final username = _usernameController.text.trim();
    if (username.isEmpty || _selectedPermissionGroupId == null || _selectedStaffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (newPassword.isNotEmpty) {
      if (newPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu phải ít nhất 6 ký tự'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu xác nhận không khớp'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      String? newAvatarUrl;
      if (_avatarFile != null) {
        newAvatarUrl = await _uploadAvatarToStorage(_uid!);
      }

      String staffName = '';
      try {
        final staffDoc =
            await _firestore.collection('staff').doc(_selectedStaffId).get();
        staffName = (staffDoc.data()?['name'] ?? '') as String;
      } catch (_) {}

      final updates = <String, dynamic>{
        'username': username,
        'permissionGroupId': _selectedPermissionGroupId,
        'staffId': _selectedStaffId,
        if (staffName.isNotEmpty) 'staffName': staffName,
        'isActive': _isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        if (newAvatarUrl != null) 'avatarUrl': newAvatarUrl,
      };

      await _firestore.collection('admin_accounts').doc(_uid).update(updates);
      await _firestore.collection('users').doc(_uid).set({
        'username': username,
        'permissionGroupId': _selectedPermissionGroupId,
        'staffId': _selectedStaffId,
        if (staffName.isNotEmpty) 'staffName': staffName,
        'status': _isActive ? 'active' : 'inactive',
        'updatedAt': FieldValue.serverTimestamp(),
        if (newAvatarUrl != null) 'avatarUrl': newAvatarUrl,
      }, SetOptions(merge: true));

      if (newPassword.isNotEmpty) {
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser != null && currentUser.uid == _uid) {
          await currentUser.updatePassword(newPassword);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể đổi mật khẩu tài khoản khác từ ứng dụng này'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật tài khoản thành công'),
          backgroundColor: _primary,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa tài khoản',
            style: TextStyle(fontWeight: FontWeight.bold, color: _onSurface)),
        content: const Text(
            'Bạn có chắc muốn xóa tài khoản nhân viên này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await _firestore.collection('admin_accounts').doc(_uid).delete();
      await _firestore.collection('users').doc(_uid).set({
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa tài khoản'), backgroundColor: _primary),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa tài khoản: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null || _uid!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Thiếu thông tin tài khoản')),
      );
    }

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
                      icon: const Icon(Icons.arrow_back_ios_new, color: _darkGreen, size: 20),
                    ),
                    const Expanded(
                      child: Text(
                        'Chỉnh sửa tài khoản',
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _primary))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      children: [
                        _buildAvatarSection(),
                        const SizedBox(height: 24),
                        _buildStaffSelector(),
                        const SizedBox(height: 20),
                        _buildPermissionDropdown(),
                        const SizedBox(height: 20),
                        _buildInput(
                          label: 'TÊN ĐĂNG NHẬP',
                          controller: _usernameController,
                          icon: Icons.account_circle,
                          hintText: 'Nhập username',
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(
                          label: 'MẬT KHẨU',
                          controller: _passwordController,
                          obscure: _obscurePassword,
                          onToggle: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          hint: 'Để trống nếu không muốn đổi mật khẩu',
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(
                          label: 'XÁC NHẬN MẬT KHẨU',
                          controller: _confirmPasswordController,
                          obscure: _obscureConfirmPassword,
                          onToggle: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        const SizedBox(height: 20),
                        _buildActiveToggle(),
                        const SizedBox(height: 32),
                        _buildSubmitButton(),
                        const SizedBox(height: 12),
                        _buildDeleteButton(),
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
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _avatarFile != null
                        ? Image.file(_avatarFile!, fit: BoxFit.cover)
                        : _avatarUrl != null
                            ? Image.network(
                                _avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Color(0xFFBECAB9),
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 40,
                                color: Color(0xFFBECAB9),
                              ),
                  ),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: _isUploadingAvatar
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          if (_avatarFile != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _avatarFile = null),
              child: Text(
                'Đặt lại ảnh',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ],
      ),
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24)],
          ),
          child: _staffDocs.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Chưa có nhân viên trong hệ thống'),
                )
              : DropdownButtonFormField<String>(
                  initialValue: _selectedStaffId,
                  isExpanded: true,
                  menuMaxHeight: 320,
                  decoration: InputDecoration(
                    hintText: 'Chọn nhân viên từ danh sách',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: _onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    prefixIcon: const Icon(Icons.person, color: _secondary, size: 22),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  icon: const Icon(Icons.expand_more, color: Color(0xFFBECAB9)),
                  style: const TextStyle(fontSize: 14, color: _onSurface),
                  dropdownColor: Colors.white,
                  items: _staffDocs.map((doc) {
                    final data = doc.data();
                    final name = (data['name'] ?? 'Không tên') as String;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedStaffId = value),
                ),
        ),
      ],
    );
  }

  Widget _buildPermissionDropdown() {
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24)],
          ),
          child: _permissionDocs.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Chưa có nhóm quyền'),
                )
              : DropdownButtonFormField<String>(
                  initialValue: _selectedPermissionGroupId,
                  isExpanded: true,
                  menuMaxHeight: 320,
                  decoration: InputDecoration(
                    hintText: 'Chọn nhóm quyền',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: _onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    prefixIcon: const Icon(Icons.shield, color: _secondary, size: 22),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  icon: const Icon(Icons.expand_more, color: Color(0xFFBECAB9)),
                  style: const TextStyle(fontSize: 14, color: _onSurface),
                  dropdownColor: Colors.white,
                  items: _permissionDocs.map((doc) {
                    final data = doc.data();
                    final name = (data['name'] ?? 'Không tên') as String;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedPermissionGroupId = value),
                ),
        ),
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
          label,
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24)],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle:
                  TextStyle(fontSize: 14, color: _onSurfaceVariant.withValues(alpha: 0.5)),
              prefixIcon: Icon(icon, color: _secondary, size: 22),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: _primary.withValues(alpha: 0.4), width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(fontSize: 14, color: _onSurface),
          ),
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
          label,
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24)],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle:
                  TextStyle(fontSize: 14, color: _onSurfaceVariant.withValues(alpha: 0.5)),
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
                  borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: _primary.withValues(alpha: 0.4), width: 1.5),
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

  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trạng thái tài khoản',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: _onSurface),
              ),
              const SizedBox(height: 2),
              Text(
                _isActive ? 'Đang kích hoạt' : 'Đã khóa',
                style: TextStyle(
                  fontSize: 12,
                  color: _isActive ? _primary : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Switch(
            value: _isActive,
            activeThumbColor: _primary,
            onChanged: (value) => setState(() => _isActive = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: const Text(
          'Lưu thay đổi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary.withValues(alpha: 0.6),
          shadowColor: _primary.withValues(alpha: 0.3),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: _isLoading ? null : _handleSave,
      ),
    );
  }

  Widget _buildDeleteButton() {
    return TextButton(
      onPressed: _isLoading ? null : _handleDeleteAccount,
      style: TextButton.styleFrom(
        foregroundColor: Colors.red.withValues(alpha: 0.7),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: const Text(
        'Xóa tài khoản nhân viên',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

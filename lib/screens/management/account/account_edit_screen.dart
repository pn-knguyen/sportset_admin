import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class AccountEditScreen extends StatefulWidget {
  const AccountEditScreen({super.key});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _uid;
  String? _selectedPermissionGroupId;
  bool _isActive = true;
  bool _isLoading = false;
  bool _initialized = false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _permissionDocs = [];

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
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_uid == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final permissionSnapshot =
          await _firestore.collection('permissions').orderBy('createdAt').get();
      final accountDoc = await _firestore.collection('admin_accounts').doc(_uid).get();

      if (!accountDoc.exists) {
        return;
      }

      final data = accountDoc.data() ?? <String, dynamic>{};
      if (!mounted) {
        return;
      }

      setState(() {
        _permissionDocs = permissionSnapshot.docs;
        _usernameController.text = (data['username'] ?? '') as String;
        _selectedPermissionGroupId = (data['permissionGroupId'] ?? '') as String;
        _isActive = data['isActive'] == true;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (_uid == null) {
      return;
    }

    final username = _usernameController.text.trim();
    if (username.isEmpty || _selectedPermissionGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập username và chọn nhóm quyền'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('admin_accounts').doc(_uid).update({
        'username': username,
        'permissionGroupId': _selectedPermissionGroupId,
        'isActive': _isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(_uid).set({
        'username': username,
        'permissionGroupId': _selectedPermissionGroupId,
        'status': _isActive ? 'active' : 'inactive',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
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

  @override
  Widget build(BuildContext context) {
    if (_uid == null || _uid!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Thiếu thông tin tài khoản')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF9800)),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    children: [
                      _buildInput(
                        label: 'Username',
                        controller: _usernameController,
                        hintText: 'Nhập username',
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionDropdown(),
                      const SizedBox(height: 16),
                      _buildActiveToggle(),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Lưu thay đổi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  'Chỉnh sửa tài khoản',
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

  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0C1C46),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isActive ? 'Kích hoạt' : 'Khóa',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          Switch(
            value: _isActive,
            activeColor: const Color(0xFFFF9800),
            onChanged: (value) => setState(() => _isActive = value),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0C1C46),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFFF9800),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF0C1C46),
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
          'Nhóm quyền',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0C1C46),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPermissionGroupId,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFFF9800),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF0C1C46),
          ),
          items: _permissionDocs.map((doc) {
            final data = doc.data();
            final name = (data['name'] ?? 'Không tên') as String;
            return DropdownMenuItem(
              value: doc.id,
              child: Text(name),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedPermissionGroupId = value),
        ),
      ],
    );
  }
}

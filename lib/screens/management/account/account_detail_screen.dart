import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class AccountDetailScreen extends StatelessWidget {
  const AccountDetailScreen({super.key});

  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _secondary = Color(0xFF18A5A7);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final uid = args?['uid'] as String?;

    if (uid == null || uid.isEmpty) {
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
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: _darkGreen,
                        size: 20,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Chi tiết tài khoản',
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
            Expanded(child: _buildBody(context, uid)),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _buildBody(BuildContext context, String uid) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('admin_accounts')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải chi tiết: ${snapshot.error}'));
        }

        final doc = snapshot.data;
        if (doc == null || !doc.exists) {
          return const Center(child: Text('Tài khoản không tồn tại'));
        }

        final data = doc.data() ?? <String, dynamic>{};
        final username = (data['username'] ?? '') as String;
        final staffName = (data['staffName'] ?? '') as String;
        final staffId = (data['staffId'] ?? '') as String;
        final authEmail = (data['authEmail'] ?? '') as String;
        final permissionGroupId = (data['permissionGroupId'] ?? '') as String;
        final isActive = data['isActive'] == true;
        final createdAt = data['createdAt'] as Timestamp?;
        final avatarUrl = data['avatarUrl'] as String?;
        final isAdmin = username == 'admin';

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // Avatar
            Center(
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
                      child: avatarUrl != null
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? _primary : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        isActive ? 'Hoạt động' : 'Đã khóa',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Username
            Center(
              child: Text(
                username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _onSurface,
                ),
              ),
            ),
            if (staffName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  staffName,
                  style: TextStyle(
                    fontSize: 13,
                    color: _onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Card: Thông tin tài khoản
            _buildCard(
              icon: Icons.account_circle,
              title: 'THÔNG TIN TÀI KHOẢN',
              children: [
                _buildRow(Icons.alternate_email, 'Email đăng nhập', authEmail),
                _buildPermissionRow(permissionGroupId),
                _buildRow(
                  isActive ? Icons.check_circle : Icons.cancel,
                  'Trạng thái',
                  isActive ? 'Hoạt động' : 'Đã khóa',
                  valueColor: isActive ? _primary : Colors.red,
                ),
                _buildRow(
                    Icons.calendar_today, 'Ngày tạo', _formatTimestamp(createdAt)),
              ],
            ),
            const SizedBox(height: 16),
            // Card: Liên kết hệ thống
            _buildCard(
              icon: Icons.link,
              title: 'LIÊN KẾT HỆ THỐNG',
              children: [
                _buildRow(Icons.badge, 'Nhân viên', staffName),
                _buildRow(Icons.fingerprint, 'UID', uid, mono: true),
                _buildRow(Icons.person_pin, 'Staff ID', staffId, mono: true),
              ],
            ),
            const SizedBox(height: 32),
            // Edit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit, color: Colors.white),
                label: Text(
                  isAdmin ? 'Tài khoản Admin (Bảo vệ)' : 'Chỉnh sửa tài khoản',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAdmin
                      ? _onSurfaceVariant.withValues(alpha: 0.4)
                      : _primary,
                  shadowColor: _primary.withValues(alpha: 0.3),
                  elevation: isAdmin ? 0 : 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: isAdmin
                    ? null
                    : () async {
                        final updated = await Navigator.pushNamed(
                          context,
                          AppRoutes.accountEdit,
                          arguments: {'uid': uid},
                        );
                        if (updated == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã cập nhật tài khoản'),
                              backgroundColor: _primary,
                            ),
                          );
                        }
                      },
              ),
            ),
            const SizedBox(height: 12),
            // Delete button
            TextButton(
              onPressed: isAdmin
                  ? null
                  : () async {
                      final deleted = await Navigator.pushNamed(
                        context,
                        AppRoutes.accountDelete,
                        arguments: {'uid': uid, 'username': username},
                      );
                      if (deleted == true && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              style: TextButton.styleFrom(
                foregroundColor: isAdmin
                    ? _onSurfaceVariant.withValues(alpha: 0.3)
                    : Colors.red.withValues(alpha: 0.7),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Xóa tài khoản nhân viên',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: _secondary, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool mono = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _onSurfaceVariant.withValues(alpha: 0.6)),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: _onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? _onSurface,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow(String permissionGroupId) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('permissions')
          .doc(permissionGroupId)
          .get(),
      builder: (context, snapshot) {
        final name = snapshot.data?.data()?['name'] as String?;
        final display = permissionGroupId.isEmpty
            ? '--'
            : name ?? permissionGroupId;
        return _buildRow(Icons.shield, 'Nhóm quyền', display,
            valueColor: _secondary);
      },
    );
  }

  String _formatTimestamp(Timestamp? value) {
    if (value == null) return '--';
    final d = value.toDate();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year} $hour:$minute';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class AccountDetailScreen extends StatelessWidget {
  const AccountDetailScreen({super.key});

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
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody(context, uid)),
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
                  'Chi tiết tài khoản',
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

  Widget _buildBody(BuildContext context, String uid) {
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: firestore.collection('admin_accounts').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF9800)),
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

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            _buildInfoCard(
              title: 'Thông tin tài khoản',
              children: [
                _buildInfoRow('Username', username),
                _buildInfoRow('Email đăng nhập', authEmail),
                _buildPermissionGroupRow(permissionGroupId),
                _buildInfoRow('Trạng thái', isActive ? 'Hoạt động' : 'Khóa'),
                _buildInfoRow('Tạo lúc', _formatTimestamp(createdAt)),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: 'Liên kết hệ thống',
              children: [
                _buildInfoRow('UID', uid),
                _buildInfoRow('Nhân viên', staffName),
                _buildInfoRow('Staff ID', staffId),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: username == 'admin'
                          ? null
                          : () async {
                              final deleted = await Navigator.pushNamed(
                                context,
                                AppRoutes.accountDelete,
                                arguments: {
                                  'uid': uid,
                                  'username': username,
                                },
                              );

                              if (deleted == true && context.mounted) {
                                Navigator.pop(context, true);
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: username == 'admin' ? Colors.grey : Colors.red,
                        side: BorderSide(
                          color: username == 'admin'
                              ? Colors.grey.withValues(alpha: 0.3)
                              : Colors.red,
                          width: 2,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Xóa tài khoản',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: username == 'admin'
                              ? Colors.grey[400]
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: username == 'admin'
                          ? LinearGradient(
                              colors: [
                                Colors.grey.withValues(alpha: 0.5),
                                Colors.grey.withValues(alpha: 0.5),
                              ],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFFFF9500), Color(0xFFF44336)],
                            ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: username == 'admin'
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: username == 'admin'
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
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                        child: Center(
                          child: Text(
                            username == 'admin'
                                ? 'Tài khoản Admin (Bảo vệ)'
                                : 'Chỉnh sửa tài khoản',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0C1C46),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionGroupRow(String permissionGroupId) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('permissions')
          .doc(permissionGroupId)
          .get(),
      builder: (context, snapshot) {
        final permissionName = snapshot.data?.data()?['name'] as String?;
        final display = permissionGroupId.isEmpty
            ? '--'
            : permissionName == null
                ? permissionGroupId
                : '$permissionName ($permissionGroupId)';

        return _buildInfoRow('Nhóm quyền', display);
      },
    );
  }

  String _formatTimestamp(Timestamp? value) {
    if (value == null) {
      return '--';
    }

    final date = value.toDate();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

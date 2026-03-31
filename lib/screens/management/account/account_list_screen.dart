import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  final int _currentNavIndex = 1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildAccountList()),
        ],
      ),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
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
                  'Danh sách tài khoản',
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

  Widget _buildAccountList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('admin_accounts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF9800)),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải tài khoản: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('Chưa có tài khoản nào'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          itemBuilder: (context, index) {
            final uid = docs[index].id;
            final data = docs[index].data();
            final username = (data['username'] ?? '') as String;
            final staffName = (data['staffName'] ?? '') as String;
            final permissionGroupId = (data['permissionGroupId'] ?? '') as String;
            final isActive = data['isActive'] == true;
            final createdAt = data['createdAt'] as Timestamp?;

            return _buildAccountCard(
              uid: uid,
              username: username,
              staffName: staffName,
              permissionGroupId: permissionGroupId,
              isActive: isActive,
              createdAt: createdAt,
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: docs.length,
        );
      },
    );
  }

  Widget _buildAccountCard({
    required String uid,
    required String username,
    required String staffName,
    required String permissionGroupId,
    required bool isActive,
    required Timestamp? createdAt,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.accountDetail,
          arguments: {'uid': uid},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF3E0),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Color(0xFFC26A00),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username.isEmpty ? 'Không có username' : username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0C1C46),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        staffName.isEmpty ? 'Chưa gắn nhân viên' : staffName,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                      _buildPermissionGroupText(permissionGroupId),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Hoạt động' : 'Khóa',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 10),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(
                  'Tạo lúc: ${_formatTimestamp(createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionGroupText(String permissionGroupId) {
    if (permissionGroupId.isEmpty) {
      return const Text(
        'Nhóm quyền: Chưa có',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _firestore.collection('permissions').doc(permissionGroupId).get(),
      builder: (context, snapshot) {
        final permissionName = snapshot.data?.data()?['name'] as String?;
        final text = permissionName == null
            ? 'Nhóm quyền: $permissionGroupId'
            : 'Nhóm quyền: $permissionName';

        return Row(
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 16,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFab() {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.accountCreate);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
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

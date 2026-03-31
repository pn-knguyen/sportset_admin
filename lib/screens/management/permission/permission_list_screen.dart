import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportset_admin/models/permission.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/services/permission_service.dart';
import 'package:sportset_admin/services/setup_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class PermissionListScreen extends StatefulWidget {
  const PermissionListScreen({super.key});

  @override
  State<PermissionListScreen> createState() => _PermissionListScreenState();
}

class _PermissionListScreenState extends State<PermissionListScreen> {
  final int _currentNavIndex = 1;
  int _selectedTabIndex = 0;
  final PermissionService _permissionService = PermissionService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AccessControlService _accessControlService = AccessControlService();

  bool _isCheckingPermission = true;
  bool _canManagePermissionGroups = false;

  @override
  void initState() {
    super.initState();
    _loadPermissionAccess();
  }

  Future<void> _loadPermissionAccess() async {
    try {
      if (!mounted) {
        return;
      }

      setState(() {
        _canManagePermissionGroups = false;
      });

      final allowed =
          await _accessControlService.canManagePermissionGroupsForCurrentUser();
      if (!mounted) {
        return;
      }

      setState(() {
        _canManagePermissionGroups = allowed;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _canManagePermissionGroups = false;
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCheckingPermission = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildPermissionTab()
                : _buildAccountTab(),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildPermissionTab() {
    if (_isCheckingPermission) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF9800)),
      );
    }

    return StreamBuilder<List<Permission>>(
      stream: _permissionService.getAllPermissionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: const Color(0xFFFF9800),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final permissions = snapshot.data ?? [];
        if (permissions.isEmpty) {
          return const Center(child: Text('Chưa có nhóm quyền'));
        }

        return Column(
          children: [
            if (!_canManagePermissionGroups)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: Color(0xFFC26A00)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bạn chỉ có quyền xem nhóm quyền.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC26A00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: permissions.map((permission) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildGroupCard(permission),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Danh sách tài khoản',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0C1C46),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemBuilder: (context, index) {
                  final uid = docs[index].id;
                  final data = docs[index].data();
                  return _buildAccountCard(
                    uid: uid,
                    username: (data['username'] ?? '') as String,
                    staffName: (data['staffName'] ?? '') as String,
                    permissionGroupId:
                        (data['permissionGroupId'] ?? '') as String,
                    isActive: data['isActive'] == true,
                    createdAt: data['createdAt'] as Timestamp?,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: docs.length,
              );
            },
          ),
        ),
      ],
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
        child: Column(
          children: [
            Padding(
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
                      'Phân quyền nhân viên',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      label: 'Nhóm quyền',
                      active: _selectedTabIndex == 0,
                      onTap: () => setState(() => _selectedTabIndex = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      label: 'Tài khoản',
                      active: _selectedTabIndex == 1,
                      onTap: () => setState(() => _selectedTabIndex = 1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? const Color(0xFFFF9800) : const Color(0xFFE5E7EB),
              width: active ? 3 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? const Color(0xFF0C1C46) : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(Permission permission) {
    final isAdminGroup = permission.name == 'Admin';

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          permission.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0C1C46),
                          ),
                        ),
                        if (isAdminGroup)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Bảo vệ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      permission.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: !_canManagePermissionGroups || isAdminGroup
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.permissionEdit,
                              arguments: {'id': permission.id},
                            );
                          },
                    tooltip: isAdminGroup ? 'Không thể chỉnh sửa nhóm Admin' : null,
                    icon: const Icon(Icons.edit, size: 20),
                    color: Colors.grey[500],
                  ),
                  IconButton(
                    onPressed: !_canManagePermissionGroups || isAdminGroup
                        ? null
                        : () async {
                            await _permissionService.deletePermission(
                              permission.id,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã xóa "${permission.name}"'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                    tooltip: isAdminGroup ? 'Không thể xóa nhóm Admin' : null,
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red[300],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${permission.assignedCount} thành viên',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
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
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF3E0),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFC26A00),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username.isEmpty ? 'Không có username' : username,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0C1C46),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        staffName.isEmpty ? 'Chưa gắn nhân viên' : staffName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
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
                    const SizedBox(height: 6),
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
            _buildPermissionGroupText(permissionGroupId),
            const SizedBox(height: 4),
            Text(
              'Tạo lúc: ${_formatTimestamp(createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
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

        return Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
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
          if (_selectedTabIndex == 0) {
            if (!_canManagePermissionGroups) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bạn không có quyền tạo hoặc chỉnh sửa nhóm quyền'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            Navigator.pushNamed(context, AppRoutes.permissionCreate);
            return;
          }

          Navigator.pushNamed(context, AppRoutes.accountCreate);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

}

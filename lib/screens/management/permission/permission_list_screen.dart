import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportset_admin/models/permission.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/services/permission_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class PermissionListScreen extends StatefulWidget {
  const PermissionListScreen({super.key});

  @override
  State<PermissionListScreen> createState() => _PermissionListScreenState();
}

class _PermissionListScreenState extends State<PermissionListScreen> {
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _secondary = Color(0xFF18A5A7);
  static const _tertiary = Color(0xFF994700);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF3F4A3C);

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
        // ignore: control_flow_in_finally
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
            _buildHeader(context),
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildPermissionTab()
                  : _buildAccountTab(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _buildPermissionTab() {
    if (_isCheckingPermission) {
      return const Center(
        child: CircularProgressIndicator(color: _primary),
      );
    }

    return StreamBuilder<List<Permission>>(
      stream: _permissionService.getAllPermissionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
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
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: _darkGreen),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bạn chỉ có quyền xem nhóm quyền.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: permissions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final permission = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildGroupCard(permission, index),
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
                    color: _onSurface,
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
                  child: CircularProgressIndicator(color: _primary),
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
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemCount: docs.length,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
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
                    'Phân quyền Nhân viên',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? _primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? _primary : _onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(Permission permission, int index) {
    final isAdminGroup = permission.name == 'Admin';
    const colorPalette = [
      _primary,
      _tertiary,
      _secondary,
      Color(0xFF7C3AED),
    ];
    const iconPalette = [
      Icons.shield,
      Icons.stadium,
      Icons.person,
      Icons.payments,
    ];
    final color = colorPalette[index % colorPalette.length];
    final icon = iconPalette[index % iconPalette.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, color: color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Text(
                                  permission.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _onSurface,
                                  ),
                                ),
                                if (isAdminGroup)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Bảo vệ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Opacity(
                                opacity:
                                    (!_canManagePermissionGroups || isAdminGroup)
                                        ? 0.4
                                        : 1.0,
                                child: GestureDetector(
                                  onTap: !_canManagePermissionGroups ||
                                          isAdminGroup
                                      ? null
                                      : () => Navigator.pushNamed(
                                            context,
                                            AppRoutes.permissionEdit,
                                            arguments: {'id': permission.id},
                                          ),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: _lightGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit,
                                        size: 16, color: _secondary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Opacity(
                                opacity:
                                    (!_canManagePermissionGroups || isAdminGroup)
                                        ? 0.4
                                        : 1.0,
                                child: GestureDetector(
                                  onTap: !_canManagePermissionGroups ||
                                          isAdminGroup
                                      ? null
                                      : () async {
                                          await _permissionService
                                              .deletePermission(permission.id);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Đã xóa "${permission.name}"'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFDAD6)
                                          .withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.delete,
                                        size: 16, color: Color(0xFFBA1A1A)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        permission.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${permission.assignedCount} thành viên',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
                    color: _lightGreen,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: _darkGreen,
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
                          color: _onSurface,
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
          color: _onSurfaceVariant,
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
            color: _onSurfaceVariant,
          ),
        );
      },
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        if (_selectedTabIndex == 0) {
          if (!_canManagePermissionGroups) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bạn không có quyền tạo hoặc chỉnh sửa nhóm quyền'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
            return;
          }
          Navigator.pushNamed(context, AppRoutes.permissionCreate);
          return;
        }
        Navigator.pushNamed(context, AppRoutes.accountCreate);
      },
      backgroundColor: _primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add, size: 32, color: Colors.white),
    );
  }

}

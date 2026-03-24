import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class PermissionListScreen extends StatefulWidget {
  const PermissionListScreen({super.key});

  @override
  State<PermissionListScreen> createState() => _PermissionListScreenState();
}

class _PermissionListScreenState extends State<PermissionListScreen> {
  final int _currentNavIndex = 1;
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _accounts = [
    {
      'name': 'Trần Minh Tú',
      'email': 'minhtu.tran@sportset.vn',
      'role': 'Quản lý sân',
      'avatarUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC_nGxk6FqATlcNvKcHkDAtHATkFSkxmFa_VDMNFso2PcaoGfVyJ9y4Sdmg09mtC622TGXqondr8ksa7jQkx48wY0onUeL4o9W8c-R_o3KmeI3Vz-vKRmlQ81kC8RWjK7rwhyTVL_-SeqSc5A-2Gx3RdoFevBu7HBzsO3Pjg1oH2jaC1jkuaQYuawOJ5lT3tBEt9Q1qV8UUldpCmNdo7xNj7pIuyLx9oiFYW9Ndol_aFsow8upfeA-A5Hzm0XLPYWyYo3FNTAyseTJ6',
      'initials': 'TM',
      'avatarBg': const Color(0xFFE3F2FD),
      'avatarFg': const Color(0xFF1565C0),
      'actionIcon': Icons.admin_panel_settings,
    },
    {
      'name': 'Lê Thị Hoa',
      'email': 'hoa.le@sportset.vn',
      'role': 'Nhân viên lễ tân',
      'avatarUrl': null,
      'initials': 'LH',
      'avatarBg': const Color(0xFFE3F2FD),
      'avatarFg': const Color(0xFF1565C0),
      'actionIcon': Icons.vpn_key,
    },
    {
      'name': 'Phạm Văn Nam',
      'email': 'nam.pham@sportset.vn',
      'role': 'Kỹ thuật viên',
      'avatarUrl': null,
      'initials': 'PN',
      'avatarBg': const Color(0xFFF3E5F5),
      'avatarFg': const Color(0xFF7B1FA2),
      'actionIcon': Icons.vpn_key,
    },
    {
      'name': 'Nguyễn Thu Hà',
      'email': 'ha.nguyen@sportset.vn',
      'role': 'Kế toán',
      'avatarUrl': null,
      'initials': 'NH',
      'avatarBg': const Color(0xFFE8F5E9),
      'avatarFg': const Color(0xFF2E7D32),
      'actionIcon': Icons.vpn_key,
    },
    {
      'name': 'Đỗ Anh',
      'email': 'doanh@sportset.vn',
      'role': 'Marketing',
      'avatarUrl': null,
      'initials': 'DA',
      'avatarBg': const Color(0xFFFFF3E0),
      'avatarFg': const Color(0xFFEF6C00),
      'actionIcon': Icons.vpn_key,
    },
  ];

  final List<Map<String, dynamic>> _permissionGroups = [
    {
      'name': 'Quản lý toàn diện',
      'description':
          'Toàn quyền hệ thống, quản lý nhân sự, cấu hình và tài chính.',
      'members': 2,
      'dotColor': const Color(0xFF22C55E),
    },
    {
      'name': 'Quản lý sân',
      'description':
          'Quản lý lịch đặt sân, check-in khách hàng và báo cáo doanh thu ngày.',
      'members': 4,
      'dotColor': const Color(0xFFFB923C),
    },
    {
      'name': 'Nhân viên lễ tân',
      'description': 'Chỉ quản lý đơn đặt, bán hàng tại quầy và check-in.',
      'members': 6,
      'dotColor': const Color(0xFF60A5FA),
    },
    {
      'name': 'Kế toán',
      'description': 'Xem báo cáo tài chính, quản lý phiếu thu chi và công nợ.',
      'members': 1,
      'dotColor': const Color(0xFFC084FC),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                if (_selectedTabIndex == 0)
                  ..._accounts.map(
                    (account) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildAccountCard(account),
                    ),
                  ),
                if (_selectedTabIndex == 1)
                  ..._permissionGroups.map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildGroupCard(group),
                    ),
                  ),
              ],
            ),
          ),
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
                      label: 'Tài khoản',
                      active: _selectedTabIndex == 0,
                      onTap: () => setState(() => _selectedTabIndex = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      label: 'Nhóm quyền',
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

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final avatarUrl = account['avatarUrl'] as String?;

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          _buildAvatar(
            avatarUrl: avatarUrl,
            initials: account['initials'] as String,
            bg: account['avatarBg'] as Color,
            fg: account['avatarFg'] as Color,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0C1C46),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  account['email'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFE0B2)),
                  ),
                  child: Text(
                    account['role'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC26A00),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.permissionEdit,
                arguments: account,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                account['actionIcon'] as IconData,
                color: const Color(0xFFFF9800),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({
    required String? avatarUrl,
    required String initials,
    required Color bg,
    required Color fg,
  }) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(avatarUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      height: 56,
      width: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4),
        ],
      ),
      child: Text(
        initials,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    final members = group['members'] as int;

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
                    Text(
                      group['name'] as String,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0C1C46),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group['description'] as String,
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
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.permissionEdit,
                        arguments: group,
                      );
                    },
                    icon: const Icon(Icons.edit, size: 20),
                    color: Colors.grey[500],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.permissionDelete,
                        arguments: group,
                      );
                    },
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
                  color: group['dotColor'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$members thành viên',
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
            Navigator.pushNamed(context, AppRoutes.staffCreate);
            return;
          }

          Navigator.pushNamed(context, AppRoutes.permissionCreate);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}

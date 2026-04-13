import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';

// Design tokens
const _primary = Color(0xFF4CAF50);
const _secondary = Color(0xFF18A5A7);
const _darkGreen = Color(0xFF2E7D32);
const _lightGreen = Color(0xFFE8F5E9);
const _onSurface = Color(0xFF1A1C1C);
const _onSurfaceVariant = Color(0xFF5C615A);
const _systemGray = Color(0xFF9E9E9E);

class ManagementScreen extends StatefulWidget {
  final bool showBottomNav;

  const ManagementScreen({super.key, this.showBottomNav = true});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  int _currentNavIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.showBottomNav ? _buildBottomNav() : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lightGreen, Colors.white],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildSectionTitle('Cơ sở & Sân bãi'),
                    const SizedBox(height: 16),
                    _buildFacilityGrid(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Vận hành & Kinh doanh'),
                    const SizedBox(height: 12),
                    _buildOperationList(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Khách hàng & Phản hồi'),
                    const SizedBox(height: 12),
                    _buildCustomerList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Flexible(
              child: Text(
                'Trung Tâm Quản Lý',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _darkGreen,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Chào buổi sáng,',
                      style: TextStyle(
                        fontSize: 12,
                        color: _onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Text(
                      'Quản trị viên',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Stack(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBPiG6-C9F_PaYJilUIHw6RkFrr1dKSspLVXSHZcs0zn7vXEPd2BCc45mr9TPBB09kDBN7up8783MIokySCVBZhz6BeBzYR-SdFeutBZ09cwdhy142rJhtpEJzW8NO9Qq0U-1krHjKroPd_gLn9iN1v-Yh_zHwGX9bqvm_ZgVERfs0XbKE7oy8eahoE9uCEA0lxP7ezICxGXSgMa6n6KILchprnDYaE-TpPWytfW8nja4YC7ZnC9StRc-OE01NmB5bMCWK6_Kw0mOo',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityGrid() {
    final tiles = [
      _FacilityTileData(
        icon: Icons.apartment,
        label: 'Danh sách\ncơ sở',
        route: AppRoutes.facilities,
      ),
      _FacilityTileData(
        icon: Icons.add_circle,
        label: 'Thêm\ncơ sở mới',
        route: AppRoutes.facilityCreate,
      ),
      _FacilityTileData(
        icon: Icons.stadium,
        label: 'Danh sách\nsân',
        route: AppRoutes.courts,
      ),
      _FacilityTileData(
        icon: Icons.add_circle,
        label: 'Thêm\nsân mới',
        route: AppRoutes.courtCreate,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const int crossAxisCount = 2;
        const double spacing = 16;
        final double itemWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
            crossAxisCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: tiles.map((t) {
            return SizedBox(
              width: itemWidth,
              child: _buildGridTile(
                icon: t.icon,
                label: t.label,
                onTap: () => Navigator.pushNamed(context, t.route),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildGridTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _primary.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: _secondary, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationList() {
    return Column(
      children: [
        _buildListRow(
          icon: Icons.category_rounded,
          title: 'Quản lý Danh mục môn thể thao',
          onTap: () => Navigator.pushNamed(context, AppRoutes.sports),
        ),
        const SizedBox(height: 12),
        _buildListRow(
          icon: Icons.confirmation_number_rounded,
          title: 'Quản lý Voucher & Khuyến mãi',
          onTap: () => Navigator.pushNamed(context, AppRoutes.vouchers),
        ),
        const SizedBox(height: 12),
        _buildListRow(
          icon: Icons.badge_rounded,
          title: 'Quản lý Nhân viên',
          onTap: () => Navigator.pushNamed(context, AppRoutes.staff),
        ),
        const SizedBox(height: 12),
        _buildListRow(
          icon: Icons.bar_chart_rounded,
          title: 'Báo cáo doanh thu chi tiết',
          onTap: () => Navigator.pushNamed(context, AppRoutes.revenue),
        ),
        const SizedBox(height: 12),
        _buildListRow(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Quản lý phân quyền',
          onTap: () => Navigator.pushNamed(context, AppRoutes.permissions),
        ),
      ],
    );
  }

  Widget _buildCustomerList() {
    return Column(
      children: [
        _buildListRow(
          icon: Icons.group_rounded,
          title: 'Danh sách khách hàng',
          onTap: () => Navigator.pushNamed(context, AppRoutes.customers),
        ),
        const SizedBox(height: 12),
        _buildListRow(
          icon: Icons.rate_review_rounded,
          title: 'Quản lý đánh giá & nhận xét',
          onTap: () => Navigator.pushNamed(context, AppRoutes.reviews),
        ),
      ],
    );
  }

  Widget _buildListRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF4F4F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _secondary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFD4D4D8), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Trang chủ', AppRoutes.home),
              _buildNavItem(1, Icons.grid_view_rounded, Icons.grid_view_outlined, 'Quản lý', AppRoutes.management),
              _buildNavItem(2, Icons.confirmation_number_rounded, Icons.confirmation_number_outlined, 'Đơn đặt', AppRoutes.bookings),
              _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded, 'Tài khoản', AppRoutes.account),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, String route) {
    final isActive = _currentNavIndex == index;
    final color = isActive ? _primary : _systemGray;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isActive) return;
          setState(() => _currentNavIndex = index);
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon, size: 26, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FacilityTileData {
  final IconData icon;
  final String label;
  final String route;
  const _FacilityTileData({
    required this.icon,
    required this.label,
    required this.route,
  });
}
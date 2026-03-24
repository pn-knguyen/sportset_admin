import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';

class ManagementScreen extends StatefulWidget {
  final bool showBottomNav;

  const ManagementScreen({super.key, this.showBottomNav = true});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  int _currentNavIndex = 1;

  static const Color _bgColor = Color(0xFFFFF8F6);
  static const Color _primaryColor = Color(0xFFFF9800);
  static const Color _navyColor = Color(0xFF0C1C46);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Cơ sở & Sân bãi'),
                  const SizedBox(height: 12),
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
      bottomNavigationBar: widget.showBottomNav ? _buildBottomNav() : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: _bgColor.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trung Tâm Quản Lý',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _navyColor,
                letterSpacing: -0.6,
              ),
            ),
            Stack(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuC_nGxk6FqATlcNvKcHkDAtHATkFSkxmFa_VDMNFso2PcaoGfVyJ9y4Sdmg09mtC622TGXqondr8ksa7jQkx48wY0onUeL4o9W8c-R_o3KmeI3Vz-vKRmlQ81kC8RWjK7rwhyTVL_-SeqSc5A-2Gx3RdoFevBu7HBzsO3Pjg1oH2jaC1jkuaQYuawOJ5lT3tBEt9Q1qV8UUldpCmNdo7xNj7pIuyLx9oiFYW9Ndol_aFsow8upfeA-A5Hzm0XLPYWyYo3FNTAyseTJ6',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
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
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _navyColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _navyColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        _buildGridTile(
          icon: Icons.apartment,
          line1: 'Danh sách',
          line2: 'cơ sở',
          onTap: () => Navigator.pushNamed(context, AppRoutes.facilities),
        ),
        _buildGridTile(
          icon: Icons.domain_add,
          line1: 'Thêm',
          line2: 'cơ sở mới',
          onTap: () => Navigator.pushNamed(context, AppRoutes.facilityCreate),
        ),
        _buildGridTile(
          icon: Icons.stadium,
          line1: 'Danh sách',
          line2: 'sân',
          onTap: () => Navigator.pushNamed(context, AppRoutes.courts),
        ),
        _buildGridTile(
          icon: Icons.add_location_alt,
          line1: 'Thêm',
          line2: 'sân mới',
          onTap: () => Navigator.pushNamed(context, AppRoutes.courtCreate),
        ),
      ],
    );
  }

  Widget _buildGridTile({
    required IconData icon,
    required String line1,
    required String line2,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _primaryColor, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                '$line1\n$line2',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperationList() {
    return Column(
      children: [
        _buildListAction(
          icon: Icons.category,
          title: 'Quản lý Danh mục môn thể thao',
          onTap: () => Navigator.pushNamed(context, AppRoutes.sports),
        ),
        const SizedBox(height: 10),
        _buildListAction(
          icon: Icons.confirmation_number,
          title: 'Quản lý Voucher & Khuyến mãi',
          onTap: () => Navigator.pushNamed(context, AppRoutes.vouchers),
        ),
        const SizedBox(height: 10),
        _buildListAction(
          icon: Icons.badge,
          title: 'Quản lý Nhân viên',
          onTap: () => Navigator.pushNamed(context, AppRoutes.staff),
        ),
        const SizedBox(height: 10),
        _buildListAction(
          icon: Icons.bar_chart,
          title: 'Báo cáo doanh thu chi tiết',
          onTap: () => Navigator.pushNamed(context, AppRoutes.revenue),
        ),
        const SizedBox(height: 10),
        _buildListAction(
          icon: Icons.shield,
          title: 'Quản lý phân quyền',
          onTap: () => Navigator.pushNamed(context, AppRoutes.permissions),
        ),
      ],
    );
  }

  Widget _buildCustomerList() {
    return Column(
      children: [
        _buildListAction(
          icon: Icons.groups,
          title: 'Danh sách khách hàng',
          onTap: () => Navigator.pushNamed(context, AppRoutes.customers),
        ),
        const SizedBox(height: 10),
        _buildListAction(
          icon: Icons.rate_review,
          title: 'Quản lý đánh giá & nhận xét',
          onTap: () => Navigator.pushNamed(context, AppRoutes.reviews),
        ),
      ],
    );
  }

  Widget _buildListAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _primaryColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[300], size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home, 'Trang chủ', AppRoutes.home),
          _buildNavItem(1, Icons.view_list, 'Quản lý', AppRoutes.management),
          _buildNavItem(2, Icons.calendar_month, 'Đơn đặt', AppRoutes.bookings),
          _buildNavItem(3, Icons.person, 'Tài khoản', AppRoutes.account),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, String route) {
    final isActive = _currentNavIndex == index;
    final color = isActive ? _primaryColor : Colors.grey[400];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isActive) {
            return;
          }

          setState(() {
            _currentNavIndex = index;
          });

          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

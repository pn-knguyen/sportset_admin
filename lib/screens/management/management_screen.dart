import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';

class ManagementScreen extends StatefulWidget {
  final bool showBottomNav;
  
  const ManagementScreen({super.key, this.showBottomNav = true});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final int _currentNavIndex = 1; // Active on Management tab
  final Color _navyColor = const Color(0xFF0C1C46);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildFacilitySection(),
                    const SizedBox(height: 32),
                    _buildOperationSection(),
                    const SizedBox(height: 32),
                    _buildCustomerSection(),
                  ],
                ),
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
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trung Tâm Quản Lý',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _navyColor,
                letterSpacing: -0.5,
              ),
            ),
            Stack(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuC_nGxk6FqATlcNvKcHkDAtHATkFSkxmFa_VDMNFso2PcaoGfVyJ9y4Sdmg09mtC622TGXqondr8ksa7jQkx48wY0onUeL4o9W8c-R_o3KmeI3Vz-vKRmlQ81kC8RWjK7rwhyTVL_-SeqSc5A-2Gx3RdoFevBu7HBzsO3Pjg1oH2jaC1jkuaQYuawOJ5lT3tBEt9Q1qV8UUldpCmNdo7xNj7pIuyLx9oiFYW9Ndol_aFsow8upfeA-A5Hzm0XLPYWyYo3FNTAyseTJ6',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
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
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _navyColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFacilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Cơ sở & Sân bãi'),
        const SizedBox(height: 2),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildGridButton(
              icon: Icons.apartment,
              label: 'Danh sách\ncơ sở',
              route: AppRoutes.facilities,
            ),
            _buildGridButton(
              icon: Icons.domain_add,
              label: 'Thêm\ncơ sở mới',
              route: AppRoutes.facilityCreate,
            ),
            _buildGridButton(
              icon: Icons.stadium,
              label: 'Danh sách\nsân',
              route: AppRoutes.courts,
            ),
            _buildGridButton(
              icon: Icons.add_location_alt,
              label: 'Thêm\nsân mới',
              route: AppRoutes.courtCreate,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridButton({
    required IconData icon,
    required String label,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
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
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Vận hành & Kinh doanh'),
        const SizedBox(height: 16),
        _buildListButton(
          icon: Icons.category,
          label: 'Quản lý Danh mục môn thể thao',
          route: AppRoutes.sports,
        ),
        const SizedBox(height: 12),
        _buildListButton(
          icon: Icons.confirmation_number,
          label: 'Quản lý Voucher & Khuyến mãi',
          route: AppRoutes.vouchers,
        ),
        const SizedBox(height: 12),
        _buildListButton(
          icon: Icons.badge,
          label: 'Quản lý Nhân viên',
          route: AppRoutes.staff,
        ),
        const SizedBox(height: 12),
        _buildListButton(
          icon: Icons.bar_chart,
          label: 'Báo cáo doanh thu chi tiết',
          route: AppRoutes.revenue,
        ),
      ],
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Khách hàng & Phản hồi'),
        const SizedBox(height: 16),
        _buildListButton(
          icon: Icons.groups,
          label: 'Danh sách khách hàng',
          route: AppRoutes.customers,
        ),
        const SizedBox(height: 12),
        _buildListButton(
          icon: Icons.rate_review,
          label: 'Quản lý đánh giá & nhận xét',
          route: AppRoutes.reviews,
        ),
      ],
    );
  }

  Widget _buildListButton({
    required IconData icon,
    required String label,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
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
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[300],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Trang chủ', AppRoutes.home),
              _buildNavItem(1, Icons.view_list, 'Quản lý', null),
              _buildNavItem(2, Icons.calendar_month, 'Đơn đặt', AppRoutes.bookings),
              _buildNavItem(3, Icons.person, 'Tài khoản', AppRoutes.account),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, String? route) {
    final isActive = _currentNavIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (route != null) {
            Navigator.pushNamed(context, route);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? const Color(0xFFFF9800) : Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFFFF9800) : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


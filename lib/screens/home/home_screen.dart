import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  final bool showBottomNav;
  
  const HomeScreen({super.key, this.showBottomNav = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'name': 'Minh Hoàng',
      'initials': 'MH',
      'court': 'Sân 7A',
      'time': '17:30 - 19:00',
      'color': Colors.blue,
    },
    {
      'name': 'Thùy Linh',
      'initials': 'TL',
      'court': 'Sân 5B',
      'time': '19:00 - 20:30',
      'color': Colors.pink,
    },
    {
      'name': 'Quốc Anh',
      'initials': 'QA',
      'court': 'Sân 7C',
      'time': '20:30 - 22:00',
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildStatsCards(),
                    const SizedBox(height: 32),
                    _buildShortcuts(),
                    const SizedBox(height: 32),
                    _buildRecentActivities(),
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
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo Section
            Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF9800), Color(0xFFF44336)],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.sports_soccer,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFF44336)],
                  ).createShader(bounds),
                  child: const Text(
                    'SPORTSET',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            
            // Profile Section
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Chào buổi sáng,',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Quản trị viên',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C0E0D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        // Revenue Card
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: Navigate to revenue details
            },
            child: Container(
              height: 144,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.payments,
                          size: 18,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                      const Icon(
                        Icons.more_horiz,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doanh thu hôm nay',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '4.850.000đ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9800),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Orders Card
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.bookings);
            },
            child: Container(
              height: 144,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          size: 18,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_upward, size: 10, color: Colors.green),
                            SizedBox(width: 2),
                            Text(
                              '12%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng số đơn đặt',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '24',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C0E0D),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'đơn',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[400],
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
          ),
        ),
      ],
    );
  }

  Widget _buildShortcuts() {
    final shortcuts = [
      {'icon': Icons.domain_add, 'label': 'Thêm\ncơ sở', 'route': AppRoutes.facilityCreate},
      {'icon': Icons.add_circle, 'label': 'Thêm\nsân', 'route': AppRoutes.courtCreate},
      {'icon': Icons.stadium, 'label': 'Danh sách\nsân', 'route': AppRoutes.courts},
      {'icon': Icons.category, 'label': 'Quản lý\ndanh mục', 'route': AppRoutes.sports},
      {'icon': Icons.card_giftcard, 'label': 'Quản lý\nVoucher', 'route': AppRoutes.vouchers},
      {'icon': Icons.groups, 'label': 'Quản lý\nnhân viên', 'route': AppRoutes.staff},
      {'icon': Icons.bar_chart, 'label': 'Báo cáo\ntổng hợp', 'route': AppRoutes.revenue},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lối tắt quản lý',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C0E0D),
          ),
        ),
        const SizedBox(height: 2),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemCount: shortcuts.length,
          itemBuilder: (context, index) {
            final shortcut = shortcuts[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, shortcut['route'] as String);
              },
              child: Column(
                children: [
                  Container(
                    height: 56,
                    width: 56,
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
                    child: Icon(
                      shortcut['icon'] as IconData,
                      size: 28,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shortcut['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hoạt động gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C0E0D),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.bookings);
              },
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF9800),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_recentActivities.length, (index) {
          final activity = _recentActivities[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
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
                    color: (activity['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      activity['initials'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: activity['color'] as Color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C0E0D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              activity['court'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${activity['time']}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                  ),
                  child: const Text(
                    'Chi tiết',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
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
              _buildNavItem(0, Icons.home, 'Trang chủ', null),
              _buildNavItem(1, Icons.view_list, 'Quản lý', AppRoutes.management),
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
          setState(() {
            _currentNavIndex = index;
          });
          if (route != null) {
            if (index == 0) {
              // Stay on home, just update state
            } else {
              Navigator.pushNamed(context, route);
            }
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


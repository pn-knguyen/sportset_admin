import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Trang quản lý voucher
class VoucherListScreen extends StatefulWidget {
  const VoucherListScreen({super.key});

  @override
  State<VoucherListScreen> createState() => _VoucherListScreenState();
}

class _VoucherListScreenState extends State<VoucherListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);

  int _selectedTabIndex = 0;

  final List<String> _tabs = ['Tất cả', 'Đang chạy', 'Sắp tới', 'Kết thúc'];

  final List<Map<String, dynamic>> _vouchers = [
    {
      'title': 'Chào Hè Sôi Động',
      'code': 'HE2024',
      'status': 'active',
      'statusText': 'Đang chạy',
      'statusColor': Colors.green,
      'used': 45,
      'total': 100,
      'discount': '-50K',
      'expiry': '30/06',
      'isEnded': false,
    },
    {
      'title': 'Siêu Sale 9.9',
      'code': 'SALE99',
      'status': 'upcoming',
      'statusText': 'Sắp tới',
      'statusColor': Colors.blue,
      'used': 0,
      'total': 500,
      'discount': '-20%',
      'expiry': '09/09',
      'isEnded': false,
    },
    {
      'title': 'Giờ Vàng Giá Sốc',
      'code': 'GIOVANG',
      'status': 'ended',
      'statusText': 'Kết thúc',
      'statusColor': Colors.grey,
      'used': 200,
      'total': 200,
      'discount': '-100K',
      'expiry': '15/05',
      'isEnded': true,
    },
    {
      'title': 'Ưu Đãi Tân Thủ',
      'code': 'NEWBIE',
      'status': 'active',
      'statusText': 'Đang chạy',
      'statusColor': Colors.green,
      'used': 12,
      'total': 1000,
      'discount': '-30K',
      'expiry': '31/12',
      'isEnded': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndTabs(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: _vouchers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildVoucherCard(_vouchers[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back, size: 24, color: _navyColor),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Quản Lý Voucher',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navyColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndTabs() {
    return Container(
      color: const Color(0xFFFFF8F6),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm mã voucher...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 24,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _navyColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _tabs.length - 1 ? 12 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? _navyColor : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? _navyColor
                              : Colors.grey.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: _navyColor.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          if (!isSelected)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 2,
                            ),
                        ],
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(Map<String, dynamic> voucher) {
    final bool isEnded = voucher['isEnded'] as bool;
    final int used = voucher['used'] as int;
    final int total = voucher['total'] as int;
    final double progress = used / total;

    return Opacity(
      opacity: isEnded ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.voucherDetail);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isEnded ? Colors.grey[50] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            boxShadow: [
              if (!isEnded)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              // Left section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher['title'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isEnded ? Colors.grey[600] : _navyColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isEnded ? Colors.white : Colors.grey[100],
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.2),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              voucher['code'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: isEnded
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: voucher['statusColor'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            voucher['statusText'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isEnded
                                  ? Colors.grey[500]
                                  : voucher['statusColor'] as Color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Đã dùng',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isEnded ? Colors.grey[600] : _navyColor,
                              ),
                              children: [
                                TextSpan(text: '$used'),
                                TextSpan(
                                  text: '/$total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: isEnded
                              ? Colors.grey[200]
                              : Colors.grey[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isEnded ? Colors.grey[500]! : _orangeColor,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Dashed divider with cutouts
              SizedBox(
                width: 1,
                height: 140,
                child: CustomPaint(
                  painter: DashedLinePainter(
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
              ),
              // Right section
              Container(
                width: 112,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEnded
                      ? Colors.grey.withValues(alpha: 0.05)
                      : _orangeColor.withValues(alpha: 0.05),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      voucher['discount'] as String,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isEnded ? Colors.grey[500] : _orangeColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'HSD: ${voucher['expiry']}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.voucherEdit);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: isEnded
                                  ? Colors.grey[400]
                                  : Colors.blue[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            _showDeleteDialog(voucher['title'] as String);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.delete,
                              size: 18,
                              color: isEnded
                                  ? Colors.grey[400]
                                  : Colors.red[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orangeColor, const Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _orangeColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.voucherCreate);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(String voucherTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Xóa voucher',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa voucher "$voucherTitle" không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa "$voucherTitle"')),
                );
              },
              child: const Text(
                'Xóa',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4;
    const dashSpace = 4;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


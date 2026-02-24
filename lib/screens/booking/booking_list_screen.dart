import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';

// Trang danh sách đơn đặt
class BookingListScreen extends StatefulWidget {
  final bool showBottomNav;
  
  const BookingListScreen({super.key, this.showBottomNav = true});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  final int _currentNavIndex = 2;
  
  int _selectedDateIndex = 0;
  int _selectedTabIndex = 0;
  
  final List<Map<String, dynamic>> _dates = [
    {'day': 'Th 2', 'date': 15},
    {'day': 'Th 3', 'date': 16},
    {'day': 'Th 4', 'date': 17},
    {'day': 'Th 5', 'date': 18},
    {'day': 'Th 6', 'date': 19},
    {'day': 'Th 7', 'date': 20},
  ];
  
  final List<Map<String, dynamic>> _pendingBookings = [
    {
      'id': '1',
      'customerName': 'Anh Hoàng',
      'phone': '0908.123.456',
      'courtName': 'Sân Chảo Lửa - Sân A1',
      'time': '18:00 - 19:30',
      'duration': '1.5h',
      'date': 'Thứ 2, 15/11/2023',
      'price': '450.000đ',
      'isNew': true,
      'avatarColor': Colors.blue,
    },
    {
      'id': '2',
      'customerName': 'Chị Lan',
      'phone': '0912.999.888',
      'courtName': 'Sân Sport Plus - Sân 7',
      'time': '20:00 - 21:00',
      'duration': '1h',
      'date': 'Thứ 2, 15/11/2023',
      'price': '300.000đ',
      'isNew': false,
      'avatarColor': Colors.purple,
    },
    {
      'id': '3',
      'customerName': 'Anh Tuấn',
      'phone': '0977.666.555',
      'courtName': 'Sân K34 - Sân 5',
      'time': '17:00 - 18:30',
      'duration': '1.5h',
      'date': 'Thứ 2, 15/11/2023',
      'price': '250.000đ',
      'isNew': false,
      'avatarColor': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 20, top: 16, right: 20, bottom: 24),
              itemCount: _pendingBookings.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildBookingCard(_pendingBookings[index]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav ? _buildBottomNav() : null,
    );
  }

  Widget _buildHeader() {
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
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text(
                'Quản Lý Đơn Đặt',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navyColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            // Date selector
            Container(
              height: 84,
              padding: const EdgeInsets.only(left: 20, bottom: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                itemBuilder: (context, index) {
                  final date = _dates[index];
                  final isSelected = _selectedDateIndex == index;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDateIndex = index;
                        });
                      },
                      child: Container(
                        width: 64,
                        decoration: BoxDecoration(
                          color: isSelected ? _navyColor : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? _navyColor : Colors.grey.withValues(alpha: 0.1),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _navyColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date['day'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w300 : FontWeight.w500,
                                color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date['date'].toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Tabs
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  _buildTab(0, 'Chờ xác nhận'),
                  _buildTab(1, 'Đã xác nhận'),
                  _buildTab(2, 'Lịch sử'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? _orangeColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? _orangeColor : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final avatarColor = booking['avatarColor'] as Color;
    final isNew = booking['isNew'] as bool;
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.bookingDetail);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Customer info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: avatarColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: avatarColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['customerName'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking['phone'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _orangeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'MỚI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _orangeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Booking details
            Column(
              children: [
                _buildDetailRow(Icons.stadium, booking['courtName']),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.schedule,
                  '${booking['time']}  |  ${booking['duration']}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.calendar_today, booking['date']),
              ],
            ),
            const SizedBox(height: 16),
            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Total price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng thanh toán',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  booking['price'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _orangeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: TextButton(
                      onPressed: () {
                        _showCancelDialog(booking);
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Hủy đơn',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_orangeColor, const Color(0xFFFF5722)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _orangeColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        _confirmBooking(booking);
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Hủy đơn đặt',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Bạn có chắc chắn muốn hủy đơn đặt của ${booking['customerName']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _pendingBookings.removeWhere((b) => b['id'] == booking['id']);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã hủy đơn đặt')),
                );
              },
              child: const Text(
                'Hủy đơn',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmBooking(Map<String, dynamic> booking) {
    setState(() {
      _pendingBookings.removeWhere((b) => b['id'] == booking['id']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xác nhận đơn đặt của ${booking['customerName']}')),
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
          _buildNavItem(0, Icons.home, 'Trang chủ'),
          _buildNavItem(1, Icons.view_list, 'Quản lý'),
          _buildNavItem(2, Icons.calendar_month, 'Đơn đặt'),
          _buildNavItem(3, Icons.person, 'Tài khoản'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentNavIndex == index;
    final color = isActive ? _orangeColor : Colors.grey[400];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // TODO: Handle navigation
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


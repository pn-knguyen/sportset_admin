import 'package:flutter/material.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);

  final Map<String, dynamic> _customerData = {
    'name': 'Nguyễn Văn Nam',
    'phone': '0987 654 321',
    'avatar': 'https://i.pravatar.cc/150?img=13',
    'tier': 'Hạng Vàng',
    'totalSpent': '5.200.000đ',
    'totalOrders': '15 đơn',
    'points': '850',
  };

  final List<Map<String, dynamic>> _bookingHistory = [
    {
      'name': 'Sân Bóng Đá Mini 01',
      'image': 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=400',
      'date': '18:00 - 24/10/2023',
      'price': '300.000đ',
      'status': 'completed',
      'statusLabel': 'Đã hoàn thành',
    },
    {
      'name': 'Sân Cầu Lông A2',
      'image': 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=400',
      'date': '09:00 - 20/10/2023',
      'price': '150.000đ',
      'status': 'cancelled',
      'statusLabel': 'Đã hủy',
    },
    {
      'name': 'Sân Tennis VIP',
      'image': 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=400',
      'date': '16:00 - 15/10/2023',
      'price': '500.000đ',
      'status': 'completed',
      'statusLabel': 'Đã hoàn thành',
    },
    {
      'name': 'Phòng Gym Zone 1',
      'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
      'date': '06:00 - 10/10/2023',
      'price': '80.000đ',
      'status': 'completed',
      'statusLabel': 'Đã hoàn thành',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildProfileSection(),
                  const SizedBox(height: 20),
                  _buildStatsSection(),
                  const SizedBox(height: 32),
                  _buildBookingHistorySection(),
                  const SizedBox(height: 24),
                  _buildContactButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: _navyColor,
                    size: 24,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Chi Tiết Khách Hàng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0C1C46),
                    letterSpacing: -0.5,
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

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange[50]!, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(_customerData['avatar'] as String),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _customerData['name'] as String,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _navyColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _customerData['phone'] as String,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFED7AA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              _customerData['tier'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB45309),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Tổng chi tiêu',
            value: _customerData['totalSpent'] as String,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Số đơn đặt',
            value: _customerData['totalOrders'] as String,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Điểm tích lũy',
            value: _customerData['points'] as String,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _navyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Lịch Sử Đặt Sân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _navyColor,
            ),
          ),
        ),
        Column(
          children: _bookingHistory.map((booking) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildBookingCard(booking),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final bool isCompleted = booking['status'] == 'completed';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(booking['image'] as String),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _navyColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking['date'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking['price'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _orangeColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isCompleted ? Colors.green[100]! : Colors.red[100]!,
                        ),
                      ),
                      child: Text(
                        booking['statusLabel'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.green[600] : Colors.red[500],
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
    );
  }

  Widget _buildContactButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFEF4444)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _orangeColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang gọi cho khách hàng...')),
          );
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.call,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Liên hệ khách hàng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


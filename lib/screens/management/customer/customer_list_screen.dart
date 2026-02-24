import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);

  final List<Map<String, dynamic>> _customers = [
    {
      'name': 'Lê Minh Anh',
      'phone': '0987 654 321',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'tier': 'gold',
      'tierLabel': 'Hạng Vàng',
      'orders': 12,
      'totalSpent': '2.400.000đ',
    },
    {
      'name': 'Trần Văn Nam',
      'phone': '0912 345 678',
      'avatar': 'https://i.pravatar.cc/150?img=13',
      'tier': 'silver',
      'tierLabel': 'Hạng Bạc',
      'orders': 5,
      'totalSpent': '850.000đ',
    },
    {
      'name': 'Nguyễn Thu Hà',
      'phone': '0909 888 777',
      'avatar': 'https://i.pravatar.cc/150?img=9',
      'tier': 'diamond',
      'tierLabel': 'Hạng Kim Cương',
      'orders': 48,
      'totalSpent': '15.200.000đ',
    },
    {
      'name': 'Phạm Quốc Hưng',
      'phone': '0933 111 222',
      'avatar': 'https://i.pravatar.cc/150?img=15',
      'tier': 'bronze',
      'tierLabel': 'Hạng Đồng',
      'orders': 2,
      'totalSpent': '300.000đ',
    },
    {
      'name': 'Vũ Thị Mai',
      'phone': '0945 666 999',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'tier': 'silver',
      'tierLabel': 'Hạng Bạc',
      'orders': 8,
      'totalSpent': '1.250.000đ',
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                _buildSearchBar(),
                const SizedBox(height: 24),
                ..._customers.map((customer) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCustomerCard(customer),
                )),
              ],
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
                  'Danh Sách Khách Hàng',
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

  Widget _buildSearchBar() {
    return Container(
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm tên hoặc SĐT khách hàng...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final tierColors = _getTierColors(customer['tier'] as String);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.customerDetail);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(customer['avatar'] as String),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          customer['name'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _navyColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: tierColors['bg'],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: tierColors['border']!),
                        ),
                        child: Text(
                          customer['tierLabel'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: tierColors['text'],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer['phone'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Đơn: ${customer['orders']}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '|',
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                      ),
                      Text(
                        customer['totalSpent'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _orangeColor,
                        ),
                      ),
                    ],
                  ),
                ],
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

  Map<String, Color> _getTierColors(String tier) {
    switch (tier) {
      case 'gold':
        return {
          'bg': const Color(0xFFFEF3C7),
          'text': const Color(0xFFB45309),
          'border': const Color(0xFFFDE68A),
        };
      case 'silver':
        return {
          'bg': const Color(0xFFF3F4F6),
          'text': const Color(0xFF4B5563),
          'border': const Color(0xFFE5E7EB),
        };
      case 'diamond':
        return {
          'bg': const Color(0xFFDBEAFE),
          'text': const Color(0xFF2563EB),
          'border': const Color(0xFFBFDBFE),
        };
      case 'bronze':
        return {
          'bg': const Color(0xFFFFEDD5),
          'text': const Color(0xFFC2410C),
          'border': const Color(0xFFFED7AA),
        };
      default:
        return {
          'bg': const Color(0xFFF3F4F6),
          'text': const Color(0xFF4B5563),
          'border': const Color(0xFFE5E7EB),
        };
    }
  }
}


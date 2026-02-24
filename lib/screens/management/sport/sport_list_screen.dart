import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Trang quản lý môn thể thao
class SportListScreen extends StatefulWidget {
  const SportListScreen({super.key});

  @override
  State<SportListScreen> createState() => _SportListScreenState();
}

class _SportListScreenState extends State<SportListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);

  final List<Map<String, dynamic>> _sports = [
    {
      'name': 'Bóng đá',
      'icon': Icons.sports_soccer,
      'count': '12 sân hiện có',
    },
    {
      'name': 'Cầu lông',
      'icon': Icons.sports_tennis,
      'count': '8 sân hiện có',
    },
    {
      'name': 'Quần vợt',
      'icon': Icons.sports_tennis,
      'count': '6 sân hiện có',
    },
    {
      'name': 'Bóng rổ',
      'icon': Icons.sports_basketball,
      'count': '4 sân hiện có',
    },
    {
      'name': 'Bơi lội',
      'icon': Icons.pool,
      'count': '2 bể hiện có',
    },
    {
      'name': 'Pickleball',
      'icon': Icons.sports_handball,
      'count': '4 sân hiện có',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildSportsList(),
                ],
              ),
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
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 24,
                      color: _navyColor,
                    ),
                  ),
                ),
              ),
              Text(
                'Quản Lý Danh Mục',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navyColor,
                  letterSpacing: -0.5,
                ),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: SizedBox(width: 40),
              ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm môn thể thao...',
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSportsList() {
    return Column(
      children: _sports.map((sport) => _buildSportCard(sport)).toList(),
    );
  }

  Widget _buildSportCard(Map<String, dynamic> sport) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: _orangeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              sport['icon'] as IconData,
              size: 28,
              color: _orangeColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sport['name'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _navyColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sport['count'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.sportEdit);
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 22,
                    color: _navyColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  _showDeleteDialog(sport['name'] as String);
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: const Icon(
                    Icons.delete,
                    size: 22,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
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
          Navigator.pushNamed(context, AppRoutes.sportCreate);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showDeleteDialog(String sportName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Xóa môn thể thao',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Bạn có chắc chắn muốn xóa môn "$sportName" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa "$sportName"')),
                );
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}


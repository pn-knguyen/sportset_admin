import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// 3.2. Trang danh sách sân
class CourtListScreen extends StatefulWidget {
  const CourtListScreen({super.key});

  @override
  State<CourtListScreen> createState() => _CourtListScreenState();
}

class _CourtListScreenState extends State<CourtListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF5722);

  final List<Map<String, dynamic>> _courts = [
    {
      'name': 'Sân A1 - Sân 7 người',
      'type': 'Bóng đá',
      'icon': Icons.sports_soccer,
      'address': '123 Nguyễn Văn Cừ, Q.5, TP.HCM',
      'price': '300k',
      'status': 'available',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAt287fpn5BUVFSybt22A3j-SkxGUiMqLflxOoBb-9LEllMmly88fOIxzN3SmcYRKTNYiSN9CQM0Ngmy8uaMn26spP67zQqbvCZmr1E0rCiD-Hdak4teppD2YJVWuKagzCt4yt6E3MohEhA5mZFspMJ5Ba-SQ9W4ihoGj_1wxFPK4h_7dABGpO_EfyKA09XGH1EIv6ZaWOYGzIJ2TtooraqqiVQFA8eUNfrRkNjCTdNoTqs10AEb7VLrW6EoFLrJJSg-r0O7qRbDwo0',
    },
    {
      'name': 'Sân B2 - Cầu lông VIP',
      'type': 'Cầu lông',
      'icon': Icons.sports_tennis,
      'address': 'Tầng 3, Nhà thi đấu đa năng',
      'price': '150k',
      'status': 'maintenance',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCkMdSij_pqfT09o_6jxRDDXq48Rv7c1WhU0yRf2h-kAccwbWwk5176oljN6fx4C_XBbafgoTPQ3sCa00ttH8lZaZleJaA-e_Taw6EiGrhYJFMMmEQSDEZEsrkKuLdsznouACFy937mP8JyId1O6ev2kqPPsqImoMBTJFcSGgV8zQwchoMXbfU_jLtl5lrgs5VAMKIlrQhMzLGZzUjs2yCB0_MGW2fvLDKSJvGgjY_FNqf5hduoC1YTT3ZqqDXCZ94YXK1Fab0DpanT',
    },
    {
      'name': 'Sân C1 - Tennis 01',
      'type': 'Tennis',
      'icon': Icons.sports_baseball,
      'address': 'Khu C, Trung tâm thể thao Quận 7',
      'price': '450k',
      'status': 'available',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA5gHliSyC9i7T9AMRiKMZDNtkqhEYImPAUQYiTiiJ4d-3NREDQLD4NkeCUS4BAHjW76t3xbYu_MpOzyNBpsOuNQyGrnJflDLS1N1Tz7absq1gc9raj70KEmTMhQj7G4zVMDJwcbmAc3S9wwF_bSQos6K-ZqMWKOyEPfQdWkE5liZ4iDMTwhyhUxS7EuYKFrUxOhVNnBlxibk8Qb0mUHNQNrMBfgGq-wbKQPSsQ8vdUTaMG6QCi3oDyJnMT05X9aPkD13GyZTggGBmH',
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
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _courts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildCourtCard(_courts[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 32),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.courtCreate);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5722), Color(0xFFFF8A65)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _orangeColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 32, color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, size: 28, color: _navyColor),
              ),
            ),
            Expanded(
              child: Text(
                'Danh Sách Sân',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm tên sân, địa chỉ...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: IconButton(
              icon: Icon(Icons.tune, color: Colors.grey[500]),
              onPressed: () {
                // TODO: Implement filter
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: _orangeColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCourtCard(Map<String, dynamic> court) {
    final isAvailable = court['status'] == 'available';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.courtDetail);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 176,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: Image.network(
                      court['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAvailable
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isAvailable ? Colors.green[500] : Colors.red[500],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAvailable ? 'Sẵn sàng' : 'Bảo trì',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isAvailable ? Colors.green[600] : Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _navyColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          court['icon'] as IconData,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          court['type'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          court['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _navyColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: court['price'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _orangeColor,
                              ),
                            ),
                            TextSpan(
                              text: '/h',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          court['address'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.courtEdit);
                          },
                          icon: const Icon(Icons.edit, size: 20),
                          label: const Text(
                            'Chỉnh sửa',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[50],
                            foregroundColor: _navyColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 56,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            _showDeleteDialog(court['name']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.05),
                            foregroundColor: Colors.red[400],
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.red.withValues(alpha: 0.05)),
                            ),
                          ),
                          child: const Icon(Icons.delete, size: 20),
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
    );
  }

  void _showDeleteDialog(String courtName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Bạn có chắc chắn muốn xóa "$courtName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa "$courtName"'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}




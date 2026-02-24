import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// 3.1. Trang danh sách cơ sở
class FacilityListScreen extends StatefulWidget {
  const FacilityListScreen({super.key});

  @override
  State<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends State<FacilityListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final int _currentNavIndex = 1; // Active on Management tab
  final Color _navyColor = const Color(0xFF0C1C46);

  final List<Map<String, dynamic>> _facilities = [
    {
      'name': 'SPORTSET Tân Bình',
      'address': '123 Đường Cộng Hòa, Phường 12, Quận Tân Bình, TP.HCM',
      'hours': '06:00 - 22:00',
      'facilities': '8 sân bóng, 4 cầu lông',
      'status': 'open',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB7w8fpVo5-tgNfEONPIXYfp_7vpzu1J022O3CRAKZsUIbhmPH6IVj2t9k6mM3SBUZB6pBsjwNO53mVGL6T6OYoUlKCwJ9IuymcbZBYixCZLdmklQekud8ACTzw0oRVC-NFiCb7dcNK-YXjqI2UumxfWOFttdVr52Nz1OIYvtCK3XjkUSWK6QAwytYlXxtexDFk5v3aMhHMxxmBvvgaovfBe2DncTqY7UI-4xYJsUzX8j3pV6Aa2jFk9jo945joEVY8vwYhWhLC74-0',
    },
    {
      'name': 'SPORTSET Quận 7 Premium',
      'address': '45 Nguyễn Thị Thập, P. Tân Phong, Quận 7, TP.HCM',
      'hours': '05:30 - 23:00',
      'facilities': '6 sân Tennis, 2 Hồ bơi',
      'status': 'open',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBV3Fnfh5rzduAwmaq--28r5aoBqfqymDZQwgybA4V8kidoxyfnqiHKCkUDaEOT2Sa-FWA2FpMFDQo9nOq_k_edx_t1AAWRlaWTfSU4XTdW67vcGilgadCMKihNQiS3gEh5lZUH_GCxd3mGtsVz6lpJgLB_QmC1fqwQ58gtZtfGYfelISylF7z4_ljALgUDnx-2jubDnqthS1erBaFkwMVeP6BMun55ozyQm3fzBSA5I2odEiQT_FEZp-twRCJ4T3221Pm5zAkC7UQG',
    },
    {
      'name': 'SPORTSET Gò Vấp Arena',
      'address': '88 Phạm Văn Chiêu, Phường 9, Gò Vấp, TP.HCM',
      'hours': '06:00 - 21:00',
      'facilities': '10 sân bóng, 2 sân rổ',
      'status': 'closed',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDk4PEjqW-Xm-eOKukXyctcIdiiTmq7hCMMTTNVauGGljqjhVbGSjNlQrPFoYYgDZ2AocRiKSh9Hx5l5v5XpSUgPnKzgd-RkCbNX_ZnDqlkp1WFD5ASZQL_yN5tfXZz2K8QnzOzCLTFACFreKD7tbFvT4-chrhTo-SFnLzBRi0hCAey7aAXxDxjwmaiDWfHynSpttu_GR7w2DJmi62WnJJS9JByUP6NnfItm2Tb8qyPHvXiknp6BvYCq9HH0YxcTtFLIeQn1F5T6d1c',
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
              itemCount: _facilities.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildFacilityCard(_facilities[index]),
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
            Navigator.pushNamed(context, AppRoutes.facilityCreate);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF9800), Color(0xFFF44336)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_left,
                  size: 28,
                  color: _navyColor,
                ),
              ),
            ),
            Text(
              'Danh Sách Cơ Sở',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _navyColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      color: const Color(0xFFFFF8F6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm tên cơ sở...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(
                  color: _navyColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: _navyColor,
                size: 24,
              ),
              onPressed: () {
                // TODO: Implement filter
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> facility) {
    final isOpen = facility['status'] == 'open';
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.facilityDetail);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Container(
                  height: 176,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: Image.network(
                    facility['image'],
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
              if (facility['status'] != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
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
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: isOpen ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOpen ? 'ĐANG MỞ' : 'ĐÓNG CỬA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _navyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facility['name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _navyColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFFFF5722),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        facility['address'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Info badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoBadge(Icons.schedule, facility['hours']),
                    _buildInfoBadge(Icons.stadium, facility['facilities']),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Action buttons
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.withValues(alpha: 0.05)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.facilityEdit);
                          },
                          icon: const Icon(Icons.edit_square, size: 18),
                          label: const Text(
                            'Chỉnh sửa',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navyColor.withValues(alpha: 0.05),
                            foregroundColor: _navyColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showDeleteDialog(facility['name']);
                          },
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text(
                            'Xóa',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.05),
                            foregroundColor: Colors.red,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String facilityName) {
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
          content: Text('Bạn có chắc chắn muốn xóa "$facilityName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Hủy',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement delete logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa "$facilityName"'),
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


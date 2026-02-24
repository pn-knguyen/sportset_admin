import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// 3.1. Chi tiết cơ sở (Create/Update)
class FacilityDetailScreen extends StatefulWidget {
  const FacilityDetailScreen({super.key});

  @override
  State<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen> {
  final int _currentNavIndex = 1; // Active on Management tab
  final int _currentImageIndex = 0;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeLightColor = const Color(0xFFFFB366);
  final Color _orangeBrandColor = const Color(0xFFFF5722);

  final List<String> _images = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuB5gVoEzF7_o_MbWYYodmiNl6GKWUZu7U-Jw5LyLLjpjq_imQur3RwzVLtMprnqcDuS9MXRHnW-B_DizGFkfdNuneEsFvpl8X98hm4OWSxF8iNJgmLi6MX9ajGHHLy4g33TNpjFAFZo1u-scxo2ZE73ipdwrMuatew8vRxJv1Vdaz2tvRhqArtKu108l3Uoi7GAVbwOulCh-o8As9LLq7eHW6ubDHUNuO2XP3MtjmJlKHGrnVixj8kYirCkqQ-jcCcNrqqAvkiIyzLX',
  ];

  final List<Map<String, dynamic>> _amenities = [
    {'icon': Icons.wifi, 'label': 'Wifi'},
    {'icon': Icons.local_parking, 'label': 'Gửi xe'},
    {'icon': Icons.restaurant, 'label': 'Căn tin'},
    {'icon': Icons.shower, 'label': 'Phòng tắm'},
  ];

  final List<Map<String, dynamic>> _courts = [
    {
      'name': 'Sân Bóng Đá A1',
      'type': 'Sân mini 5 người',
      'icon': Icons.sports_soccer,
      'status': 'available',
    },
    {
      'name': 'Sân Bóng Đá A2',
      'type': 'Sân mini 5 người',
      'icon': Icons.sports_soccer,
      'status': 'available',
    },
    {
      'name': 'Sân Cầu Lông 1',
      'type': 'Thảm tiêu chuẩn',
      'icon': Icons.sports_tennis,
      'status': 'maintenance',
    },
    {
      'name': 'Sân Cầu Lông 2',
      'type': 'Thảm tiêu chuẩn',
      'icon': Icons.sports_tennis,
      'status': 'available',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 104, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(),
                const SizedBox(height: 16),
                _buildFacilityInfo(),
                const SizedBox(height: 24),
                _buildAmenities(),
                const SizedBox(height: 32),
                _buildCourtsList(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
          
          // Header
          _buildHeader(),
        ],
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F6),
          border: Border(
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
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
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    size: 28,
                    color: _navyColor,
                  ),
                ),
              ),
              Text(
                'Chi Tiết Cơ Sở',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _orangeBrandColor.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                _images[_currentImageIndex],
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
          
          // Image indicators
          if (_images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: List.generate(_images.length, (index) {
                        final isActive = index == _currentImageIndex;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(isActive ? 1 : 0.6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFacilityInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'SPORTSET Tân Bình',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _navyColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'ĐANG MỞ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.location_on,
              '123 Đường Cộng Hòa, Phường 12, Quận Tân Bình, TP. Hồ Chí Minh',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.call, '0901 234 567'),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.schedule, '06:00 - 22:00'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: _orangeLightColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: icon == Icons.location_on ? Colors.grey[700] : _navyColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'TIỆN ÍCH CƠ SỞ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _navyColor,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _amenities.length,
            itemBuilder: (context, index) {
              final amenity = _amenities[index];
              return Container(
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
                    Icon(
                      amenity['icon'] as IconData,
                      color: _orangeLightColor,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      amenity['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourtsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SÂN BÃI THUỘC CƠ SỞ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                  letterSpacing: 1.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.courts);
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _orangeBrandColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _courts.map((court) => _buildCourtCard(court)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCourtCard(Map<String, dynamic> court) {
    final isAvailable = court['status'] == 'available';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              court['icon'] as IconData,
              color: _orangeLightColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _navyColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  court['type'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isAvailable 
                  ? Colors.green.withValues(alpha: 0.1) 
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAvailable ? 'Sẵn sàng' : 'Bảo trì',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isAvailable ? Colors.green[600] : Colors.red[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  _showDeleteDialog();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 2),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Xóa cơ sở',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9500), Color(0xFFF44336)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.facilityEdit);
                  },
                  child: const Center(
                    child: Text(
                      'Chỉnh sửa cơ sở',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
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
          content: const Text('Bạn có chắc chắn muốn xóa cơ sở "SPORTSET Tân Bình"?'),
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
                  const SnackBar(
                    content: Text('Đã xóa cơ sở thành công'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
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


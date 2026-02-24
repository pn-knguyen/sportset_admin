import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Chi tiết sân
class CourtDetailScreen extends StatefulWidget {
  const CourtDetailScreen({super.key});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF5722);
  final int _currentNavIndex = 1;
  
  bool _isActive = true;
  int _currentImageIndex = 0;
  
  final List<String> _images = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBrb21NH6hO3YlDaHWb3D3OwdwYZ7voV8MEJozH5v1lMmZqHY-UKzaLHN2lzj3NMNqJF1mPrCjM4Egmvv-S3od024bIr6h0GzP9GUzjegBeze2_O-bdvgcRZsQc2kdtsO79q-ckF4fPu3B6ZEAoH3TBL-8WFqziZ1lWr7jkX5OT7y3Mugqm5qzux-ZlB0s01_DhiWaBLg5ie9fBNbVCU7cSWpmBVNB3-rUbU3wK_AGesZd0q5Z6cb1WKO24_H1lZa5662m-KAREKQhb',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBrb21NH6hO3YlDaHWb3D3OwdwYZ7voV8MEJozH5v1lMmZqHY-UKzaLHN2lzj3NMNqJF1mPrCjM4Egmvv-S3od024bIr6h0GzP9GUzjegBeze2_O-bdvgcRZsQc2kdtsO79q-ckF4fPu3B6ZEAoH3TBL-8WFqziZ1lWr7jkX5OT7y3Mugqm5qzux-ZlB0s01_DhiWaBLg5ie9fBNbVCU7cSWpmBVNB3-rUbU3wK_AGesZd0q5Z6cb1WKO24_H1lZa5662m-KAREKQhb',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBrb21NH6hO3YlDaHWb3D3OwdwYZ7voV8MEJozH5v1lMmZqHY-UKzaLHN2lzj3NMNqJF1mPrCjM4Egmvv-S3od024bIr6h0GzP9GUzjegBeze2_O-bdvgcRZsQc2kdtsO79q-ckF4fPu3B6ZEAoH3TBL-8WFqziZ1lWr7jkX5OT7y3Mugqm5qzux-ZlB0s01_DhiWaBLg5ie9fBNbVCU7cSWpmBVNB3-rUbU3wK_AGesZd0q5Z6cb1WKO24_H1lZa5662m-KAREKQhb',
  ];
  
  final List<Map<String, dynamic>> _subCourts = [
    {'name': 'A1', 'fullName': 'Sân A1', 'status': 'available'},
    {'name': 'A2', 'fullName': 'Sân A2', 'status': 'available'},
    {'name': 'A3', 'fullName': 'Sân A3', 'status': 'maintenance'},
    {'name': 'A4', 'fullName': 'Sân A4', 'status': 'available'},
  ];
  
  final List<Map<String, dynamic>> _amenities = [
    {'icon': Icons.wifi, 'name': 'Wifi'},
    {'icon': Icons.local_parking, 'name': 'Gửi xe'},
    {'icon': Icons.water_drop, 'name': 'Nước'},
    {'icon': Icons.lightbulb, 'name': 'Đèn'},
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
              child: Column(
                children: [
                  _buildImageCarousel(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildCourtInfoSection(),
                        const SizedBox(height: 20),
                        _buildSubCourtsSection(),
                        const SizedBox(height: 20),
                        _buildPricingSection(),
                        const SizedBox(height: 20),
                        _buildAmenitiesSection(),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
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
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.arrow_back_ios_new, size: 24, color: _navyColor),
              ),
            ),
            Expanded(
              child: Text(
                'Chi Tiết Sân',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navyColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Implement share functionality
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.share, size: 24, color: _navyColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width * 0.625, // 16:10 aspect ratio
          color: Colors.grey[200],
          child: PageView.builder(
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                _images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  );
                },
              );
            },
          ),
        ),
        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFFFFF8F6),
                ],
              ),
            ),
          ),
        ),
        // Page indicators
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_images.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _currentImageIndex ? 24 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index == _currentImageIndex 
                      ? Colors.white 
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCourtInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cụm Sân Bóng Đá A',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _navyColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 18, color: _orangeColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '30 Phan Thúc Duyện, Tân Bình',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _orangeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _orangeColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sports_soccer, size: 14, color: _orangeColor),
                    const SizedBox(width: 4),
                    Text(
                      'Bóng đá - Sân 5',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wb_sunny, size: 14, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Ngoài trời',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trạng thái chung',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _navyColor,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Đang hoạt động',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _orangeColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Transform.scale(
                      scale: 0.9,
                      child: Switch(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                        activeThumbColor: _orangeColor,
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

  Widget _buildSubCourtsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _orangeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Danh sách sân con (${_subCourts.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subCourts.length,
            itemBuilder: (context, index) {
              final court = _subCourts[index];
              final isAvailable = court['status'] == 'available';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.grey[50] : Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isAvailable 
                        ? Colors.grey.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            court['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isAvailable ? _navyColor : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          court['fullName'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isAvailable ? _navyColor : Colors.grey[500],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAvailable 
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAvailable 
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          isAvailable ? 'Sẵn sàng' : 'Bảo trì',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isAvailable ? Colors.green[700] : Colors.red[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _orangeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Bảng giá niêm yết',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Weekday pricing
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'THỨ 2 - THỨ 6',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildPricingItem('05:00 - 16:00', '150.000đ', false),
              const SizedBox(height: 8),
              _buildPricingItem('17:00 - 23:00', '250.000đ', false),
            ],
          ),
          const SizedBox(height: 16),
          // Weekend pricing
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'CUỐI TUẦN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildPricingItem('Toàn thời gian', '300.000đ', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingItem(String time, String price, bool isWeekend) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWeekend ? _orangeColor.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWeekend 
            ? _orangeColor.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isWeekend ? _navyColor : Colors.grey[600],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isWeekend ? Colors.orange[600] : _navyColor,
              ),
              children: [
                TextSpan(text: price),
                TextSpan(
                  text: '/giờ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: isWeekend 
                      ? Colors.orange[400]
                      : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _orangeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tiện ích & Mô tả',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Amenities horizontal scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _amenities.map((amenity) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: _orangeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _orangeColor.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          amenity['icon'] as IconData,
                          size: 24,
                          color: _orangeColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        amenity['name'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Text(
              'Sân bóng đá cỏ nhân tạo mới được nâng cấp với mặt cỏ tiêu chuẩn FIFA, hệ thống thoát nước tốt. Khu vực an ninh, có canteen phục vụ nước uống giải khát. Thích hợp cho các giải đấu phong trào và tập luyện hàng ngày.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                _showDeleteDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Xóa sân',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_orangeColor, const Color(0xFFD32F2F)],
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
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.courtEdit);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_square, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Chỉnh sửa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Bạn có chắc chắn muốn xóa sân này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
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


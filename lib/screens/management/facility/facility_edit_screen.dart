import 'package:flutter/material.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Trang chỉnh sửa cơ sở
class FacilityEditScreen extends StatefulWidget {
  const FacilityEditScreen({super.key});

  @override
  State<FacilityEditScreen> createState() => _FacilityEditScreenState();
}

class _FacilityEditScreenState extends State<FacilityEditScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'SPORTSET Tân Bình');
  final TextEditingController _hotlineController = TextEditingController(text: '0901 234 567');
  final TextEditingController _addressController = TextEditingController(text: '123 Đường Cộng Hòa, Phường 12, Quận Tân Bình, TP.HCM');
  final TextEditingController _openTimeController = TextEditingController(text: '06:00');
  final TextEditingController _closeTimeController = TextEditingController(text: '22:00');
  final TextEditingController _descriptionController = TextEditingController(
      text: 'Cơ sở vật chất hiện đại với 8 sân bóng đá cỏ nhân tạo và 4 sân cầu lông đạt tiêu chuẩn thi đấu. Khu vực gửi xe rộng rãi, có căn tin phục vụ nước uống và thức ăn nhẹ.');

  final int _currentNavIndex = 1; // Active on Management tab
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);

  final String _currentImage = 'https://lh3.googleusercontent.com/aida-public/AB6AXuB7w8fpVo5-tgNfEONPIXYfp_7vpzu1J022O3CRAKZsUIbhmPH6IVj2t9k6mM3SBUZB6pBsjwNO53mVGL6T6OYoUlKCwJ9IuymcbZBYixCZLdmklQekud8ACTzw0oRVC-NFiCb7dcNK-YXjqI2UumxfWOFttdVr52Nz1OIYvtCK3XjkUSWK6QAwytYlXxtexDFk5v3aMhHMxxmBvvgaovfBe2DncTqY7UI-4xYJsUzX8j3pV6Aa2jFk9jo945joEVY8vwYhWhLC74-0';

  final List<Map<String, dynamic>> _amenities = [
    {'icon': Icons.wifi, 'label': 'Wifi', 'selected': true},
    {'icon': Icons.local_parking, 'label': 'Gửi xe', 'selected': true},
    {'icon': Icons.shower, 'label': 'Phòng tắm', 'selected': false},
    {'icon': Icons.restaurant, 'label': 'Căn tin', 'selected': true},
    {'icon': Icons.medical_services, 'label': 'Y tế', 'selected': false},
    {'icon': Icons.ac_unit, 'label': 'Máy lạnh', 'selected': true},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _hotlineController.dispose();
    _addressController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _descriptionController.dispose();
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildImageSection(),
                  const SizedBox(height: 32),
                  _buildFormFields(),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
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
                decoration: const BoxDecoration(
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
              'Chỉnh Sửa Cơ Sở',
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

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 224,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              _currentImage,
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
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.black.withValues(alpha: 0.2),
            ),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement image picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng chọn ảnh đang được phát triển')),
                  );
                },
                icon: const Icon(Icons.photo_camera, size: 20),
                label: const Text(
                  'Thay đổi ảnh',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orangeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Họ tên cơ sở',
          controller: _nameController,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Hotline',
          controller: _hotlineController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildTextArea(
          label: 'Địa chỉ',
          controller: _addressController,
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Giờ mở cửa',
                controller: _openTimeController,
                suffixIcon: Icons.schedule,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Giờ đóng cửa',
                controller: _closeTimeController,
                suffixIcon: Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextArea(
          label: 'Mô tả',
          controller: _descriptionController,
          maxLines: 4,
        ),
        const SizedBox(height: 28),
        _buildAmenities(),
        const SizedBox(height: 32),
        _buildUpdateButton(),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _navyColor,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _orangeColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: Colors.grey[400], size: 20)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _navyColor,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _orangeColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          padding: const EdgeInsets.only(left: 8, bottom: 0),
          child: Text(
            'TIỆN ÍCH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _amenities.length,
          itemBuilder: (context, index) {
            final amenity = _amenities[index];
            final isSelected = amenity['selected'] as bool;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _amenities[index]['selected'] = !isSelected;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? _orangeColor.withValues(alpha: 0.1) 
                      : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? _orangeColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      amenity['icon'] as IconData,
                      color: isSelected ? _orangeColor : Colors.grey[400],
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      amenity['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? _orangeColor : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orangeColor, const Color(0xFFF44336)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
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
            _updateFacility();
          },
          child: const Center(
            child: Text(
              'Cập nhật thay đổi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateFacility() {
    // TODO: Implement update facility logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật cơ sở thành công'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

}


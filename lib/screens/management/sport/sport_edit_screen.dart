import 'package:flutter/material.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Trang chỉnh sửa môn thể thao
class SportEditScreen extends StatefulWidget {
  const SportEditScreen({super.key});

  @override
  State<SportEditScreen> createState() => _SportEditScreenState();
}

class _SportEditScreenState extends State<SportEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);

  int _selectedIconIndex = 0;

  final List<Map<String, dynamic>> _icons = [
    {'icon': Icons.sports_soccer, 'name': 'Bóng đá'},
    {'icon': Icons.sports_tennis, 'name': 'Cầu lông'},
    {'icon': Icons.sports_basketball, 'name': 'Bóng rổ'},
    {'icon': Icons.sports_volleyball, 'name': 'Bóng chuyền'},
    {'icon': Icons.pool, 'name': 'Bơi lội'},
    {'icon': Icons.fitness_center, 'name': 'Gym'},
    {'icon': Icons.directions_run, 'name': 'Chạy bộ'},
    {'icon': Icons.sports_golf, 'name': 'Golf'},
  ];

  @override
  void initState() {
    super.initState();
    // Pre-filled data
    _nameController = TextEditingController(text: 'Bóng đá');
    _descriptionController = TextEditingController(
      text: 'Môn thể thao đồng đội chơi với quả bóng hình cầu giữa hai đội gồm 11 cầu thủ.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconSelector(),
                  const SizedBox(height: 32),
                  _buildNameField(),
                  const SizedBox(height: 24),
                  _buildDescriptionField(),
                  const SizedBox(height: 40),
                  _buildSaveButton(),
                  const SizedBox(height: 24),
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
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
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
                'Thông Tin Danh Mục',
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

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn Biểu Tượng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _navyColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: _icons.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedIconIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIconIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFF2E6)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFCC80)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) {
                        if (isSelected) {
                          return const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFF44336)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        }
                        return const LinearGradient(
                          colors: [Color(0xFF0C1C46), Color(0xFF0C1C46)],
                        ).createShader(bounds);
                      },
                      child: Icon(
                        _icons[index]['icon'] as IconData,
                        size: 32,
                        color: isSelected
                            ? Colors.white
                            : _navyColor.withValues(alpha: 0.4),
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

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Tên môn thể thao',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _navyColor,
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
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Nhập tên môn thể thao',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _navyColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Mô tả chi tiết',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _navyColor,
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
            controller: _descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Nhập mô tả chi tiết',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _navyColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orangeColor, const Color(0xFFF44336)],
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
          if (_nameController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng nhập tên môn thể thao')),
            );
            return;
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã cập nhật "${_nameController.text}"')),
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
              Icons.save,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Lưu Thông Tin',
              style: TextStyle(
                fontSize: 18,
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


import 'package:flutter/material.dart';
import 'package:sportset_admin/screens/management/sport/sport_icon_mapper.dart';
import 'package:sportset_admin/services/sport_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Trang thêm mới môn thể thao
class SportCreateScreen extends StatefulWidget {
  const SportCreateScreen({super.key});

  @override
  State<SportCreateScreen> createState() => _SportCreateScreenState();
}

class _SportCreateScreenState extends State<SportCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  final SportService _sportService = SportService();
  final AccessControlService _accessControlService = AccessControlService();

  int _selectedIconIndex = 0;
  bool _isVisible = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _checkCreatePermission();
  }
  
  Future<void> _checkCreatePermission() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    final hasPermission = _accessControlService.can(permissionMap, 'sports', 'create');
    
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền tạo môn thể thao'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconSelector(),
                  const SizedBox(height: 32),
                  _buildNameField(),
                  const SizedBox(height: 20),
                  _buildDescriptionField(),
                  const SizedBox(height: 32),
                  _buildVisibilityToggle(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
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
                'Thêm Danh Mục',
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Chọn biểu tượng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _navyColor,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: SportIconMapper.iconOptions.length,
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
                        SportIconMapper.iconOptions[index]['icon'] as IconData,
                        size: 32,
                        color: isSelected
                            ? Colors.white
                            : _navyColor.withValues(alpha: 0.3),
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
            'Tên danh mục',
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
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Bóng đá',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
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

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Mô tả',
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
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Nhập mô tả ngắn về danh mục môn thể thao này...',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
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

  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hiển thị trên ứng dụng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _navyColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Người dùng sẽ nhìn thấy danh mục này',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isVisible,
            onChanged: (value) {
              setState(() {
                _isVisible = value;
              });
            },
            activeThumbColor: _orangeColor,
            activeTrackColor: _orangeColor.withValues(alpha: 0.5),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _orangeColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextButton(
        onPressed: _isSaving
            ? null
            : () async {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tên danh mục')),
                  );
                  return;
                }

                setState(() {
                  _isSaving = true;
                });

                try {
                  await _sportService.createSport(
                    name: _nameController.text.trim(),
                    description: _descriptionController.text.trim(),
                    iconKey: SportIconMapper.iconOptions[_selectedIconIndex]['key']
                        as String,
                    isVisible: _isVisible,
                  );

                  if (!mounted) {
                    return;
                  }
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã thêm danh mục "${_nameController.text.trim()}"',
                      ),
                    ),
                  );
                    Navigator.pop(context);
                } catch (_) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tạo danh mục thất bại, vui lòng thử lại'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSaving = false;
                    });
                  }
                }
              },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          _isSaving ? 'Đang lưu...' : 'Lưu Danh Mục',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


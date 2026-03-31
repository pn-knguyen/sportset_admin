import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportset_admin/models/staff.dart';
import 'package:sportset_admin/services/staff_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class StaffCreateScreen extends StatefulWidget {
  const StaffCreateScreen({super.key});

  @override
  State<StaffCreateScreen> createState() => _StaffCreateScreenState();
}

class _StaffCreateScreenState extends State<StaffCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final StaffService _staffService = StaffService();
  final AccessControlService _accessControlService = AccessControlService();
  
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  final Color _secondaryColor = const Color(0xFFFF4E00);
  
  bool _isLoading = false;
  String? _selectedPosition;
  String? _selectedWorkplace;

  final List<Map<String, String>> _positions = [
    {'value': 'admin', 'label': 'Quản trị viên'},
    {'value': 'manager', 'label': 'Quản lý cơ sở'},
    {'value': 'staff', 'label': 'Nhân viên vận hành'},
    {'value': 'coach', 'label': 'Huấn luyện viên'},
    {'value': 'receptionist', 'label': 'Lễ tân'},
  ];

  @override
  void initState() {
    super.initState();
    _checkCreatePermission();
  }
  
  Future<void> _checkCreatePermission() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    final hasPermission = _accessControlService.can(permissionMap, 'staff', 'create');
    
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền tạo nhân viên'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildAvatarSection(),
                  const SizedBox(height: 32),
                  _buildFormFields(),
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
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF0C1C46),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Thêm Nhân Viên',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navyColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.grey[300],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // Handle image picker
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _orangeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _orangeColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'ẢNH ĐẠI DIỆN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          label: 'Họ và tên',
          controller: _nameController,
          icon: Icons.badge,
          placeholder: 'Nhập họ và tên đầy đủ',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Số điện thoại',
          controller: _phoneController,
          icon: Icons.call,
          placeholder: '0123 456 789',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Email',
          controller: _emailController,
          icon: Icons.mail,
          placeholder: 'example@sportset.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          label: 'Vị trí làm việc',
          icon: Icons.work,
          placeholder: 'Chọn vị trí',
          value: _selectedPosition,
          items: _positions,
          onChanged: (value) {
            setState(() {
              _selectedPosition = value;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildFacilityDropdown(),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String placeholder,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.grey[400],
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }



  Widget _buildFacilityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Cơ sở làm việc',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _navyColor,
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('facilities')
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                    ),
                  ],
                ),
                height: 56,
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: _orangeColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: const Text('Lỗi tải dữ liệu'),
              );
            }

            final facilities = snapshot.data?.docs ?? [];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedWorkplace,
                decoration: InputDecoration(
                  hintText: 'Chọn cơ sở',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                icon: Icon(
                  Icons.expand_more,
                  color: Colors.grey[400],
                ),
                style: TextStyle(fontSize: 14, color: _navyColor),
                dropdownColor: Colors.white,
                items: facilities.map((facility) {
                  final id = facility.id;
                  final name = facility['name'] ?? 'Unknown';
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWorkplace = value;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String placeholder,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.grey[400],
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            icon: Icon(
              Icons.expand_more,
              color: Colors.grey[400],
            ),
            style: TextStyle(fontSize: 14, color: _navyColor),
            dropdownColor: Colors.white,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(item['label']!),
              );
            }).toList(),
            onChanged: onChanged,
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
          colors: [_orangeColor, _secondaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _orangeColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextButton(
        onPressed: _isLoading ? null : _handleSave,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Thêm Nhân Viên',
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

  Future<void> _handleSave() async {
    // Validate inputs
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedPosition == null ||
        _selectedWorkplace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get facility name from selected ID
      final facilityDoc = await FirebaseFirestore.instance
          .collection('facilities')
          .doc(_selectedWorkplace)
          .get();
      final facilityName = facilityDoc['name'] ?? _selectedWorkplace ?? '';

      final now = DateTime.now();
      final newStaff = Staff(
        id: '', // Firestore will auto-generate
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        position: _selectedPosition!,
        facilityId: _selectedWorkplace!,
        facilityName: facilityName,
        status: 'active',
        avatar: null,
        permissionGroupId: '', // Can be set separately
        createdAt: now,
        updatedAt: now,
      );

      await _staffService.createStaff(newStaff);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm nhân viên thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}


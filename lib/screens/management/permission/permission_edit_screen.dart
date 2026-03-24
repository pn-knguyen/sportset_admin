import 'package:flutter/material.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class PermissionEditScreen extends StatefulWidget {
  const PermissionEditScreen({Key? key}) : super(key: key);

  @override
  State<PermissionEditScreen> createState() => _PermissionEditScreenState();
}

class _PermissionEditScreenState extends State<PermissionEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Quản lý Cơ sở & Sân',
      'icon': Icons.stadium,
      'items': [
        {'label': 'Xem danh sách', 'enabled': true},
        {'label': 'Thêm mới', 'enabled': true},
        {'label': 'Chỉnh sửa', 'enabled': true},
        {'label': 'Xóa', 'enabled': false},
      ],
    },
    {
      'title': 'Quản lý Đơn hàng',
      'icon': Icons.receipt_long,
      'items': [
        {'label': 'Duyệt đơn', 'enabled': true},
        {'label': 'Hủy đơn', 'enabled': true},
        {'label': 'Check-in khách', 'enabled': true},
      ],
    },
    {
      'title': 'Quản lý Voucher',
      'icon': Icons.local_activity,
      'items': [
        {'label': 'Tạo mã', 'enabled': false},
        {'label': 'Chỉnh sửa', 'enabled': false},
        {'label': 'Xem lịch sử dùng', 'enabled': true},
      ],
    },
    {
      'title': 'Quản lý Nhân sự',
      'icon': Icons.group,
      'items': [
        {'label': 'Xem danh sách', 'enabled': false},
        {'label': 'Phân quyền', 'enabled': false},
      ],
    },
    {
      'title': 'Báo cáo Thống kê',
      'icon': Icons.bar_chart,
      'items': [
        {'label': 'Xem doanh thu', 'enabled': false},
        {'label': 'Xuất báo cáo', 'enabled': false},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Quản lý sân');
    _descriptionController = TextEditingController(
      text: 'Toàn quyền quản lý sân và đơn đặt',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      setState(() {
        _nameController.text = args['name'] ?? 'Quản lý sân';
        _descriptionController.text = args['description'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _togglePermission(int sectionIndex, int itemIndex) {
    setState(() {
      _sections[sectionIndex]['items'][itemIndex]['enabled'] =
          !_sections[sectionIndex]['items'][itemIndex]['enabled'];
    });
  }

  void _submit() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên nhóm quyền'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật nhóm quyền'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFF8F6),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF0C1C46),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Chỉnh Sửa Nhóm Quyền',
          style: TextStyle(
            color: Color(0xFF0C1C46),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          _buildFormCard(),
          const SizedBox(height: 24),
          _buildPermissionTitle(),
          const SizedBox(height: 12),
          ..._sections.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> section = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPermissionSection(section, index),
            );
          }).toList(),
          const SizedBox(height: 12),
          _buildSaveButton(),
        ],
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          _buildInput(
            label: 'Tên nhóm quyền',
            hintText: 'Nhập tên nhóm quyền',
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          _buildInput(
            label: 'Mô tả nhóm',
            hintText: 'Nhập mô tả nhóm',
            controller: _descriptionController,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C1C46),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFFAF8F7),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
            ),
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0C1C46),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionTitle() {
    return Row(
      children: [
        const Icon(Icons.tune, color: Color(0xFFFF9800), size: 20),
        const SizedBox(width: 8),
        Text(
          'CHI TIẾT QUYỀN HẠN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionSection(
    Map<String, dynamic> section,
    int sectionIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Container(
            color: const Color(0xFFFFF3E0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(section['icon'], color: Colors.orange[700], size: 18),
                const SizedBox(width: 8),
                Text(
                  section['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C1C46),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: (section['items'] as List).asMap().entries.map((entry) {
              int itemIndex = entry.key;
              Map<String, dynamic> item = entry.value;
              bool isLast = itemIndex == (section['items'] as List).length - 1;

              return Column(
                children: [
                  Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['label'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                _togglePermission(sectionIndex, itemIndex),
                            child: Container(
                              width: 44,
                              height: 24,
                              decoration: BoxDecoration(
                                color: item['enabled']
                                    ? const Color(0xFFFF9800)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 200),
                                    left: item['enabled'] ? 22 : 2,
                                    top: 2,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: Colors.grey[100],
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFF44336)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submit,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              'Lưu Thay Đổi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

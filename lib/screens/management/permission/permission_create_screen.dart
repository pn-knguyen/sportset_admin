import 'package:flutter/material.dart';
import 'package:sportset_admin/models/permission.dart';
import 'package:sportset_admin/services/permission_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class PermissionCreateScreen extends StatefulWidget {
  const PermissionCreateScreen({super.key});

  @override
  State<PermissionCreateScreen> createState() => _PermissionCreateScreenState();
}

class _PermissionCreateScreenState extends State<PermissionCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final PermissionService _permissionService = PermissionService();

  final int _currentNavIndex = 1;
  bool _isLoading = false;

  late Map<String, dynamic> _permissions;

  @override
  void initState() {
    super.initState();
    _permissions = PermissionService.getDefaultPermissionsTemplate();
    _syncSectionsFromPermissions();
  }

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Quản lý Cơ sở & Sân',
      'icon': Icons.stadium,
      'items': [
        {'label': 'Xem danh sách', 'enabled': true},
        {'label': 'Thêm mới', 'enabled': false},
        {'label': 'Chỉnh sửa', 'enabled': false},
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
        {'label': 'Xem danh sách', 'enabled': false},
        {'label': 'Thêm mới', 'enabled': false},
        {'label': 'Chỉnh sửa', 'enabled': false},
        {'label': 'Xóa', 'enabled': false},
      ],
    },
    {
      'title': 'Quản lý Nhân viên',
      'icon': Icons.group,
      'items': [
        {'label': 'Xem danh sách', 'enabled': false},
        {'label': 'Thêm mới', 'enabled': false},
        {'label': 'Chỉnh sửa', 'enabled': false},
        {'label': 'Xóa', 'enabled': false},
        {'label': 'Phân quyền', 'enabled': false},
      ],
    },
    {
      'title': 'Quản lý Danh mục Môn thể thao',
      'icon': Icons.sports_basketball,
      'items': [
        {'label': 'Xem danh sách', 'enabled': false},
        {'label': 'Thêm mới', 'enabled': false},
        {'label': 'Chỉnh sửa', 'enabled': false},
        {'label': 'Xóa', 'enabled': false},
      ],
    },
    {
      'title': 'Báo cáo Thống kê',
      'icon': Icons.bar_chart,
      'items': [
        {'label': 'Xem doanh thu', 'enabled': true},
        {'label': 'Xuất báo cáo', 'enabled': false},
      ],
    },
  ];

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
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormCard(),
                  const SizedBox(height: 16),
                  _buildPermissionTitle(),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _sections.length,
                    (sectionIndex) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPermissionSection(sectionIndex),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCreateButton(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF0C1C46),
                  size: 20,
                ),
              ),
              const Expanded(
                child: Text(
                  'Thêm Nhóm Quyền',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0C1C46),
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tên nhóm quyền',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0C1C46),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Nhân viên kỹ thuật',
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFFFF9800)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Mô tả nhóm',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0C1C46),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Quản lý bảo trì sân',
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFFFF9800)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTitle() {
    return const Row(
      children: [
        Icon(Icons.tune, color: Color(0xFFFF9800), size: 20),
        SizedBox(width: 6),
        Text(
          'CHI TIẾT QUYỀN HẠN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionSection(int sectionIndex) {
    final section = _sections[sectionIndex];
    final items = section['items'] as List<dynamic>;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  section['icon'] as IconData,
                  color: const Color(0xFFEA7C0A),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section['title'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0C1C46),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(items.length, (itemIndex) {
            final item = items[itemIndex] as Map<String, dynamic>;
            final isLast = itemIndex == items.length - 1;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.08),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item['label'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                  Switch(
                    value: item['enabled'] as bool,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFFFF9800),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFE5E7EB),
                    onChanged: (value) {
                      setState(() {
                        (_sections[sectionIndex]['items']
                                as List<dynamic>)[itemIndex]['enabled'] =
                            value;
                        _applySectionToggleToPermissions(
                          sectionIndex,
                          itemIndex,
                          value,
                        );
                      });
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFF44336)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9800).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleCreate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
              : const Text(
                  'Tạo Nhóm Quyền',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handleCreate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhóm quyền')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final newPermission = Permission(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        permissions: _permissions,
        assignedCount: 0,
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      await _permissionService.createPermission(newPermission);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo nhóm quyền mới'),
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

  void _syncSectionsFromPermissions() {
    for (var sectionIndex = 0; sectionIndex < _sections.length; sectionIndex++) {
      final items = _sections[sectionIndex]['items'] as List<dynamic>;
      for (var itemIndex = 0; itemIndex < items.length; itemIndex++) {
        items[itemIndex]['enabled'] = _isPermissionEnabled(sectionIndex, itemIndex);
      }
    }
  }

  bool _isPermissionEnabled(int sectionIndex, int itemIndex) {
    switch (sectionIndex) {
      case 0:
        switch (itemIndex) {
          case 0:
            return _getPermissionValue('facilities', 'view') &&
                _getPermissionValue('courts', 'view');
          case 1:
            return _getPermissionValue('facilities', 'create') &&
                _getPermissionValue('courts', 'create');
          case 2:
            return _getPermissionValue('facilities', 'update') &&
                _getPermissionValue('courts', 'update');
          case 3:
            return _getPermissionValue('facilities', 'delete') &&
                _getPermissionValue('courts', 'delete');
        }
        break;
      case 1:
        switch (itemIndex) {
          case 0:
            return _getPermissionValue('bookings', 'approve');
          case 1:
            return _getPermissionValue('bookings', 'cancel');
          case 2:
            return _getPermissionValue('bookings', 'check_in');
        }
        break;
      case 2:
        switch (itemIndex) {
          case 0:
            return _getPermissionValue('vouchers', 'view');
          case 1:
            return _getPermissionValue('vouchers', 'create');
          case 2:
            return _getPermissionValue('vouchers', 'update');
          case 3:
            return _getPermissionValue('vouchers', 'delete');
        }
        break;
      case 3:
        switch (itemIndex) {
          case 0:
            return _getPermissionValue('staff', 'view');
          case 1:
            return _getPermissionValue('staff', 'create');
          case 2:
            return _getPermissionValue('staff', 'update');
          case 3:
            return _getPermissionValue('staff', 'delete');
          case 4:
            return _getPermissionValue('staff', 'assign_permissions');
        }
        break;
      case 4:
        switch (itemIndex) {
          case 0:
            return _getPermissionValue('sports', 'view');
          case 1:
            return _getPermissionValue('sports', 'create');
          case 2:
            return _getPermissionValue('sports', 'update');
          case 3:
            return _getPermissionValue('sports', 'delete');
        }
        break;
      case 5:
        switch (itemIndex) {
          case 0:
            return _getPermissionValue('reports', 'view');
          case 1:
            return _getPermissionValue('reports', 'export');
        }
        break;
    }

    return false;
  }

  void _applySectionToggleToPermissions(
    int sectionIndex,
    int itemIndex,
    bool value,
  ) {
    switch (sectionIndex) {
      case 0:
        switch (itemIndex) {
          case 0:
            _setPermissionValue('facilities', 'view', value);
            _setPermissionValue('courts', 'view', value);
            return;
          case 1:
            _setPermissionValue('facilities', 'create', value);
            _setPermissionValue('courts', 'create', value);
            return;
          case 2:
            _setPermissionValue('facilities', 'update', value);
            _setPermissionValue('courts', 'update', value);
            return;
          case 3:
            _setPermissionValue('facilities', 'delete', value);
            _setPermissionValue('courts', 'delete', value);
            return;
        }
        return;
      case 1:
        switch (itemIndex) {
          case 0:
            _setPermissionValue('bookings', 'approve', value);
            return;
          case 1:
            _setPermissionValue('bookings', 'cancel', value);
            return;
          case 2:
            _setPermissionValue('bookings', 'check_in', value);
            return;
        }
        return;
      case 2:
        switch (itemIndex) {
          case 0:
            _setPermissionValue('vouchers', 'view', value);
            return;
          case 1:
            _setPermissionValue('vouchers', 'create', value);
            return;
          case 2:
            _setPermissionValue('vouchers', 'update', value);
            return;
          case 3:
            _setPermissionValue('vouchers', 'delete', value);
            return;
        }
        return;
      case 3:
        switch (itemIndex) {
          case 0:
            _setPermissionValue('staff', 'view', value);
            return;
          case 1:
            _setPermissionValue('staff', 'create', value);
            return;
          case 2:
            _setPermissionValue('staff', 'update', value);
            return;
          case 3:
            _setPermissionValue('staff', 'delete', value);
            return;
          case 4:
            _setPermissionValue('staff', 'assign_permissions', value);
            return;
        }
        return;
      case 4:
        switch (itemIndex) {
          case 0:
            _setPermissionValue('sports', 'view', value);
            return;
          case 1:
            _setPermissionValue('sports', 'create', value);
            return;
          case 2:
            _setPermissionValue('sports', 'update', value);
            return;
          case 3:
            _setPermissionValue('sports', 'delete', value);
            return;
        }
        return;
      case 5:
        switch (itemIndex) {
          case 0:
            _setPermissionValue('reports', 'view', value);
            return;
          case 1:
            _setPermissionValue('reports', 'export', value);
            return;
        }
        return;
    }
  }

  bool _getPermissionValue(String module, String action) {
    final moduleData = _permissions[module] as Map<String, dynamic>?;
    final value = moduleData?[action];
    return value is bool ? value : false;
  }

  void _setPermissionValue(String module, String action, bool value) {
    final moduleData =
        (_permissions[module] as Map<String, dynamic>?) ?? <String, dynamic>{};
    moduleData[action] = value;
    _permissions[module] = moduleData;
  }
}
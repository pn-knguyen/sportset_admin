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
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _secondary = Color(0xFF18A5A7);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF3F4A3C);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final PermissionService _permissionService = PermissionService();

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
        {'label': 'Xem đơn hàng', 'enabled': false},
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
    {
      'title': 'Quản lý Tài khoản',
      'icon': Icons.admin_panel_settings,
      'items': [
        {'label': 'Xem danh sách', 'enabled': false},
        {'label': 'Thêm mới', 'enabled': false},
        {'label': 'Chỉnh sửa', 'enabled': false},
        {'label': 'Xóa', 'enabled': false},
      ],
    },
    {
      'title': 'Cài đặt hệ thống',
      'icon': Icons.settings,
      'items': [
        {'label': 'Xem cài đặt', 'enabled': false},
        {'label': 'Cập nhật cài đặt', 'enabled': false},
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
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_lightGreen, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: _darkGreen,
                        size: 20,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Thêm Nhóm Quyền',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildPermissionTitle(),
                    const SizedBox(height: 12),
                    ...List.generate(
                      _sections.length,
                      (sectionIndex) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPermissionSection(sectionIndex),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCreateButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _buildFormCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tên nhóm quyền',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: TextField(
            controller: _nameController,
            style: const TextStyle(color: _onSurface, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Nhân viên kỹ thuật',
              hintStyle: TextStyle(
                  color: _onSurfaceVariant.withValues(alpha: 0.4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: Colors.black.withValues(alpha: 0.05)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: Colors.black.withValues(alpha: 0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: _primary.withValues(alpha: 0.4), width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Mô tả nhóm quyền',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: const TextStyle(color: _onSurface, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Quản lý bảo trì sân',
              hintStyle: TextStyle(
                  color: _onSurfaceVariant.withValues(alpha: 0.4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: Colors.black.withValues(alpha: 0.05)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: Colors.black.withValues(alpha: 0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: _primary.withValues(alpha: 0.4), width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionTitle() {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Danh sách quyền hạn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _darkGreen,
          ),
        ),
      ],
    );
  }

  IconData _itemIcon(String label) {
    switch (label) {
      case 'Xem danh sách':
        return Icons.visibility_outlined;
      case 'Thêm mới':
        return Icons.add_circle_outline;
      case 'Chỉnh sửa':
        return Icons.edit_outlined;
      case 'Xóa':
        return Icons.delete_outline;
      case 'Duyệt đơn':
        return Icons.check_circle_outline;
      case 'Hủy đơn':
        return Icons.cancel_outlined;
      case 'Check-in khách':
        return Icons.how_to_reg;
      case 'Tạo mã':
        return Icons.add_card;
      case 'Xem lịch sử dùng':
        return Icons.history;
      case 'Phân quyền':
        return Icons.manage_accounts;
      case 'Xem doanh thu':
        return Icons.payments_outlined;
      case 'Xuất báo cáo':
        return Icons.file_download_outlined;
      case 'Xem đơn hàng':
        return Icons.receipt_long;
      case 'Xem cài đặt':
        return Icons.settings_outlined;
      case 'Cập nhật cài đặt':
        return Icons.tune_outlined;
      default:
        return Icons.toggle_on_outlined;
    }
  }

  Widget _buildPermissionSection(int sectionIndex) {
    final section = _sections[sectionIndex];
    final items = section['items'] as List<dynamic>;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: _lightGreen,
              child: Row(
                children: [
                  Icon(
                    section['icon'] as IconData,
                    color: _primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: List.generate(items.length, (itemIndex) {
                  final item = items[itemIndex] as Map<String, dynamic>;
                  final label = item['label'] as String;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(_itemIcon(label), color: _secondary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _onSurfaceVariant,
                            ),
                          ),
                        ),
                        Switch(
                          value: item['enabled'] as bool,
                          activeThumbColor: Colors.white,
                          trackColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return _primary;
                            }
                            return Colors.grey[200];
                          }),
                          onChanged: (value) {
                            setState(() {
                              (_sections[sectionIndex]['items']
                                      as List<dynamic>)[itemIndex]
                                  ['enabled'] = value;
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreate,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
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
            : const Text(
                'Tạo Nhóm Quyền',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
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
            return _getPermissionValue('bookings', 'view');
          case 1:
            return _getPermissionValue('bookings', 'approve');
          case 2:
            return _getPermissionValue('bookings', 'cancel');
          case 3:
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
      case 6:
        switch (itemIndex) {
          case 0:
            return _getPermissionValue('accounts', 'view');
          case 1:
            return _getPermissionValue('accounts', 'create');
          case 2:
            return _getPermissionValue('accounts', 'update');
          case 3:
            return _getPermissionValue('accounts', 'delete');
        }
        break;
      case 7:
        switch (itemIndex) {
          case 0:
            return _getPermissionValue('settings', 'view');
          case 1:
            return _getPermissionValue('settings', 'update');
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
            _setPermissionValue('bookings', 'view', value);
            return;
          case 1:
            _setPermissionValue('bookings', 'approve', value);
            return;
          case 2:
            _setPermissionValue('bookings', 'cancel', value);
            return;
          case 3:
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
      case 6:
        switch (itemIndex) {
          case 0:
            _setPermissionValue('accounts', 'view', value);
            return;
          case 1:
            _setPermissionValue('accounts', 'create', value);
            return;
          case 2:
            _setPermissionValue('accounts', 'update', value);
            return;
          case 3:
            _setPermissionValue('accounts', 'delete', value);
            return;
        }
        return;
      case 7:
        switch (itemIndex) {
          case 0:
            _setPermissionValue('settings', 'view', value);
            return;
          case 1:
            _setPermissionValue('settings', 'update', value);
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
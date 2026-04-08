import 'package:flutter/material.dart';
import 'package:sportset_admin/services/permission_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class PermissionEditScreen extends StatefulWidget {
  const PermissionEditScreen({super.key});

  @override
  State<PermissionEditScreen> createState() => _PermissionEditScreenState();
}

class _PermissionEditScreenState extends State<PermissionEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final PermissionService _permissionService = PermissionService();

  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _secondary = Color(0xFF18A5A7);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);

  String? _permissionId;
  bool _isLoading = false;

  late Map<String, dynamic> _permissions;

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Quản lý Cơ sở & Sân',
      'icon': Icons.stadium,
      'items': [
        {'label': 'Xem danh sách', 'enabled': false},
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
        {'label': 'Duyệt đơn', 'enabled': false},
        {'label': 'Hủy đơn', 'enabled': false},
        {'label': 'Check-in khách', 'enabled': false},
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
        {'label': 'Xem doanh thu', 'enabled': false},
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
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _permissions = PermissionService.getDefaultPermissionsTemplate();
    _syncSectionsFromPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _permissionId = args?['id'] as String?;
    
    if (_permissionId != null) {
      _loadPermission();
    }
  }

  Future<void> _loadPermission() async {
    if (_permissionId == null) return;
    
    try {
      final permission = await _permissionService.getPermissionByIdFuture(_permissionId!);
      if (permission != null && mounted) {
        setState(() {
          _nameController.text = permission.name;
          _descriptionController.text = permission.description;
          _permissions = permission.permissions;
          _syncSectionsFromPermissions();
        });
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
      final nextValue =
          !(_sections[sectionIndex]['items'][itemIndex]['enabled'] as bool);
      _sections[sectionIndex]['items'][itemIndex]['enabled'] = nextValue;
      _applySectionToggleToPermissions(sectionIndex, itemIndex, nextValue);
    });
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên nhóm quyền'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_permissionId == null) return;

    setState(() => _isLoading = true);

    try {
      await _permissionService.updatePermission(_permissionId!, {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'permissions': _permissions,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật nhóm quyền'),
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
                        'Chỉnh sửa Nhóm quyền',
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  _buildPermissionTitle(),
                  const SizedBox(height: 12),
                  ..._sections.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPermissionSection(entry.value, entry.key),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildSaveButton(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _primary.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildInput(
            label: 'Tên nhóm quyền',
            hintText: 'Nhập tên nhóm quyền...',
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          _buildInput(
            label: 'Mô tả nhóm',
            hintText: 'Nhập mô tả...',
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
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
                color: _onSurfaceVariant.withValues(alpha: 0.4),
                fontWeight: FontWeight.normal),
            filled: true,
            fillColor: _lightGreen.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: _primary.withValues(alpha: 0.5), width: 2),
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

  Widget _buildPermissionSection(
    Map<String, dynamic> section,
    int sectionIndex,
  ) {
    final items = section['items'] as List;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: _primary.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: _lightGreen,
              child: Row(
                children: [
                  Icon(section['icon'] as IconData, color: _primary, size: 20),
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
                children: items.asMap().entries.map((entry) {
                  final itemIndex = entry.key;
                  final item = entry.value as Map<String, dynamic>;
                  final label = item['label'] as String;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(_itemIcon(label), color: _secondary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _onSurfaceVariant,
                            ),
                          ),
                        ),
                        Switch(
                          value: item['enabled'] as bool,
                          activeThumbColor: Colors.white,
                          trackColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return _primary;
                            }
                            return Colors.grey[200];
                          }),
                          onChanged: (value) =>
                              _togglePermission(sectionIndex, itemIndex),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
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
                'Lưu Thay Đổi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
      ),
    );
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

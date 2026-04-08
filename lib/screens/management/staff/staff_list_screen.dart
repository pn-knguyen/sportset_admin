import 'package:flutter/material.dart';
import 'package:sportset_admin/models/staff.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/services/staff_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StaffService _staffService = StaffService();
  final AccessControlService _accessControlService = AccessControlService();
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);
  static const _secondary = Color(0xFF00696B);

  String _searchQuery = '';
  int _selectedChip = 0;
  final List<String> _chips = ['Tất cả', 'Quản lý', 'Trực sân', 'Kế toán'];

  bool _canCreate = false;
  bool _canEdit = false;
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  Future<void> _checkPermissions() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    setState(() {
      _canCreate = _accessControlService.can(permissionMap, 'staff', 'create');
      _canEdit = _accessControlService.can(permissionMap, 'staff', 'update');
      _canDelete = _accessControlService.can(permissionMap, 'staff', 'delete');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lightGreen, Colors.white],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          size: 22, color: _onSurfaceVariant),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Qu\u1ea3n l\u00fd nh\u00e2n vi\u00ean',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _darkGreen,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert,
                          size: 22, color: _darkGreen),
                      onPressed: null,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Staff>>(
                stream: _staffService.getAllStaffStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _primary),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('L\u1ed7i: ${snapshot.error}'));
                  }
                  final allStaff = snapshot.data ?? [];
                  final filtered = _applyFilters(allStaff);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: 'T\u00ecm ki\u1ebfm nh\u00e2n vi\u00ean...',
                            hintStyle:
                                TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                  color: _primary, width: 2),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          itemCount: _chips.length,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedChip == index;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _selectedChip = index),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _primary
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: Colors.grey.shade200),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: _primary.withValues(
                                                  alpha: 0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.03),
                                              blurRadius: 4,
                                            )
                                          ],
                                  ),
                                  child: Text(
                                    _chips[index],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (filtered.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'Kh\u00f4ng t\u00ecm th\u1ea5y nh\u00e2n vi\u00ean',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[500]),
                            ),
                          ),
                        ),
                      ...filtered.map((staff) => Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: _buildStaffCard(staff),
                          )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _canCreate
            ? () => Navigator.pushNamed(context, AppRoutes.staffCreate)
            : null,
        backgroundColor: _primary,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  List<Staff> _applyFilters(List<Staff> allStaff) {
    var filtered = allStaff.where((staff) {
      final q = _searchQuery.toLowerCase();
      return staff.name.toLowerCase().contains(q) ||
          staff.email.toLowerCase().contains(q);
    }).toList();
    if (_selectedChip == 1) {
      filtered = filtered
          .where((s) => s.position == 'admin' || s.position == 'manager')
          .toList();
    } else if (_selectedChip == 2) {
      filtered =
          filtered.where((s) => s.position == 'staff').toList();
    } else if (_selectedChip == 3) {
      filtered = filtered
          .where(
              (s) => s.position == 'receptionist' || s.position == 'coach')
          .toList();
    }
    return filtered;
  }

  String _getPositionLabel(String position) {
    final positions = {
      'admin': 'Quản trị viên',
      'manager': 'Quản lý cơ sở',
      'staff': 'Nhân viên vận hành',
      'coach': 'Huấn luyện viên',
      'receptionist': 'Lễ tân',
    };
    return positions[position] ?? position;
  }

  String _getStatusLabel(String status) {
    final statuses = {
      'active': 'Đang làm việc',
      'inactive': 'Ngừng hoạt động',
      'suspended': 'Tạm dừng',
    };
    return statuses[status] ?? status;
  }

  Widget _buildStaffCard(Staff staff) {
    final isActive = staff.status == 'active';
    final roleColor = isActive ? _primary : _secondary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: staff.avatar != null && staff.avatar!.isNotEmpty
                      ? Image.network(
                          staff.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, err, stack) => Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.grey[400],
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 36,
                          color: Colors.grey[400],
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              staff.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: _onSurface,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _lightGreen
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              isActive
                                  ? '\u0110ang ho\u1ea1t \u0111\u1ed9ng'
                                  : _getStatusLabel(staff.status),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? _darkGreen
                                    : Colors.grey.shade600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPositionLabel(staff.position).toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: roleColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: _onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              staff.facilityName,
                              style: const TextStyle(
                                  fontSize: 13, color: _onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.call_outlined,
                              size: 14, color: _onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            staff.phone.isNotEmpty
                                ? staff.phone
                                : staff.email,
                            style: const TextStyle(
                                fontSize: 13, color: _onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCardAction(
                    icon: Icons.edit,
                    label: 'Ch\u1ec9nh s\u1eeda',
                    bgColor: Colors.grey.shade100,
                    textColor: _onSurface,
                    enabled: _canEdit,
                    onTap: _canEdit
                        ? () => Navigator.pushNamed(
                              context,
                              AppRoutes.staffEdit,
                              arguments: {'id': staff.id},
                            )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCardAction(
                    icon: Icons.delete_outline,
                    label: 'X\u00f3a',
                    bgColor:
                        const Color(0xFFFFDAD6).withValues(alpha: 0.4),
                    textColor: const Color(0xFFBA1A1A),
                    enabled: _canDelete,
                    onTap: _canDelete
                        ? () => _showDeleteDialog(staff.name, staff.id)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAction({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? bgColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: enabled ? textColor : Colors.grey[400]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: enabled ? textColor : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String staffName, String staffId) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Xóa nhân viên',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa nhân viên "$staffName" không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await _staffService.deleteStaff(staffId);
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Đã xóa "$staffName"'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Xóa',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


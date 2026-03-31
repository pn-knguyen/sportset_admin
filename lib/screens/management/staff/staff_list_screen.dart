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
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  final Color _statusGreen = const Color(0xFF22C55E);
  final Color _deleteRed = const Color(0xFFFFEBEE);
  final Color _deleteIconColor = const Color(0xFFEF4444);
  String _searchQuery = '';
  
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
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<Staff>>(
              stream: _staffService.getAllStaffStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: _orangeColor),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi: ${snapshot.error}'),
                  );
                }

                final allStaff = snapshot.data ?? [];
                final filteredStaff = allStaff
                    .where((staff) =>
                        staff.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        staff.email
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                    .toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    if (filteredStaff.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'Không tìm thấy nhân viên',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                    ...filteredStaff.map(
                      (staff) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildStaffCard(staff),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
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
                  child: Icon(Icons.chevron_left, color: _navyColor, size: 24),
                ),
              ),
              const Expanded(
                child: Text(
                  'Quản Lý Nhân Viên',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C1C46),
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

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm nhân viên...',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  child: Icon(Icons.close, color: Colors.grey[400], size: 20),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return _statusGreen;
      case 'inactive':
        return Colors.grey;
      case 'suspended':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStaffCard(Staff staff) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.staffEdit,
          arguments: {'id': staff.id},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange[50]!, width: 2),
                color: Colors.grey[200],
              ),
              child: staff.avatar != null
                  ? ClipOval(
                      child: Image.network(
                        staff.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 28,
                            color: Colors.grey[400],
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 28,
                      color: Colors.grey[400],
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _navyColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getPositionLabel(staff.position),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    staff.facilityName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _getStatusColor(staff.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusLabel(staff.status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(staff.status),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: _canEdit
                      ? () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.staffEdit,
                            arguments: {'id': staff.id},
                          );
                        }
                      : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _canEdit ? Colors.grey[50] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: _canEdit ? _navyColor : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _canDelete
                      ? () {
                          _showDeleteDialog(staff.name, staff.id);
                        }
                      : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _canDelete ? _deleteRed : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete,
                      size: 20,
                      color: _canDelete ? _deleteIconColor : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orangeColor, const Color(0xFFF44336)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _orangeColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.staffCreate);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(String staffName, String staffId) {
    final scaffoldContext = context; // Save outer context reference
    showDialog(
      context: scaffoldContext,
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
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Text('Đã xóa "$staffName"'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
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


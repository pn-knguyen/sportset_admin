import 'package:flutter/material.dart';
import 'package:sportset_admin/models/sport.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/screens/management/sport/sport_icon_mapper.dart';
import 'package:sportset_admin/services/sport_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Trang quản lý môn thể thao
class SportListScreen extends StatefulWidget {
  const SportListScreen({super.key});

  @override
  State<SportListScreen> createState() => _SportListScreenState();
}

class _SportListScreenState extends State<SportListScreen> {
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF3F4A3C);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final int _currentNavIndex = 1;
  final SportService _sportService = SportService();
  final AccessControlService _accessControlService = AccessControlService();
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
      _canCreate = _accessControlService.can(permissionMap, 'sports', 'create');
      _canEdit = _accessControlService.can(permissionMap, 'sports', 'update');
      _canDelete = _accessControlService.can(permissionMap, 'sports', 'delete');
    });
  }

  List<Sport> _filterSports(List<Sport> sports) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return sports;
    }

    return sports.where((sport) {
      return sport.name.toLowerCase().contains(query) ||
          sport.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGreen,
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
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildSportsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: _darkGreen),
                padding: const EdgeInsets.all(8),
              ),
            ),
            const Text(
              'Quản lý Danh mục',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _darkGreen,
                letterSpacing: -0.5,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => _searchFocusNode.requestFocus(),
                icon: const Icon(Icons.search, size: 22, color: _darkGreen),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm môn thể thao...',
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _onSurfaceVariant,
          ),
          prefixIcon: Icon(Icons.search, color: _onSurfaceVariant, size: 22),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: _primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _onSurface,
        ),
      ),
    );
  }

  Widget _buildSportsList() {
    return StreamBuilder<List<Sport>>(
      stream: _sportService.getAllSportsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Không thể tải danh mục môn thể thao',
            style: TextStyle(color: Colors.red[400]),
          );
        }

        final sports = _filterSports(snapshot.data ?? <Sport>[]);
        if (sports.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Text(
              _searchQuery.isEmpty
                  ? 'Chưa có danh mục môn thể thao nào'
                  : 'Không tìm thấy danh mục phù hợp',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        return Column(
          children: sports.map((sport) => _buildSportCard(sport)).toList(),
        );
      },
    );
  }

  Widget _buildSportCard(Sport sport) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              SportIconMapper.iconFromKey(sport.iconKey),
              size: 28,
              color: _primary,
            ),
          ),
          const SizedBox(width: 14),
          // Name + count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sport.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${sport.itemCount} sân hiện có',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Edit button
          IconButton(
            onPressed: _canEdit
                ? () => Navigator.pushNamed(
                      context,
                      AppRoutes.sportEdit,
                      arguments: {'id': sport.id},
                    )
                : null,
            icon: Icon(
              Icons.edit_outlined,
              size: 22,
              color: _canEdit ? const Color(0xFF18A5A7) : Colors.grey[300],
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          // Delete button
          IconButton(
            onPressed: _canDelete ? () => _showDeleteDialog(sport) : null,
            icon: Icon(
              Icons.delete_outline,
              size: 22,
              color: _canDelete ? const Color(0xFFBA1A1A) : Colors.grey[300],
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: _canCreate ? _primary : Colors.grey[400],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (_canCreate ? _primary : Colors.grey).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _canCreate
            ? () => Navigator.pushNamed(context, AppRoutes.sportCreate)
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(Sport sport) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Xóa môn thể thao',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Bạn có chắc chắn muốn xóa môn "${sport.name}" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await _sportService.deleteSport(sport.id);
                  if (!mounted) {
                    return;
                  }
                  messenger.showSnackBar(
                    SnackBar(content: Text('Đã xóa "${sport.name}"')),
                  );
                } catch (_) {
                  if (!mounted) {
                    return;
                  }
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Xóa danh mục thất bại, vui lòng thử lại'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}


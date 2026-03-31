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
  final TextEditingController _searchController = TextEditingController();
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
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
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildSportsList(),
                ],
              ),
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
                'Quản Lý Danh Mục',
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm môn thể thao...',
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
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
      padding: const EdgeInsets.all(12),
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
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: _orangeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              SportIconMapper.iconFromKey(sport.iconKey),
              size: 28,
              color: _orangeColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sport.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _navyColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${sport.itemCount} sân hiện có',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sport.isVisible ? 'Đang hiển thị' : 'Đang ẩn',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: sport.isVisible ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.sportDetail,
                    arguments: {'id': sport.id},
                  );
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Icon(
                    Icons.visibility,
                    size: 22,
                    color: _orangeColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _canEdit
                    ? () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.sportEdit,
                          arguments: {'id': sport.id},
                        );
                      }
                    : null,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 22,
                    color: _canEdit ? _navyColor : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _canDelete
                    ? () {
                        _showDeleteDialog(sport);
                      }
                    : null,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Icon(
                    Icons.delete,
                    size: 22,
                    color: _canDelete ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return _canCreate
        ? Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_orangeColor, const Color(0xFFFF5722)],
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
                Navigator.pushNamed(context, AppRoutes.sportCreate);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.add,
                size: 32,
                color: Colors.white,
              ),
            ),
          )
        : Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withValues(alpha: 0.5),
                  Colors.grey.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(
                Icons.add,
                size: 32,
                color: Colors.grey[400],
              ),
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


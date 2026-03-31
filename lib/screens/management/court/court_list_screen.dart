import 'package:flutter/material.dart';
import 'package:sportset_admin/models/court.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/services/court_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// 3.2. Trang danh sách sân
class CourtListScreen extends StatefulWidget {
  const CourtListScreen({super.key});

  @override
  State<CourtListScreen> createState() => _CourtListScreenState();
}

class _CourtListScreenState extends State<CourtListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF5722);
  final CourtService _courtService = CourtService();
  final AccessControlService _accessControlService = AccessControlService();
  
  bool _canView = true;
  bool _canCreate = false;
  bool _canEdit = false;
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    _checkPermissions();
  }
  
  Future<void> _checkPermissions() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    setState(() {
      _canCreate = _accessControlService.can(permissionMap, 'courts', 'create');
      _canEdit = _accessControlService.can(permissionMap, 'courts', 'update');
      _canDelete = _accessControlService.can(permissionMap, 'courts', 'delete');
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
          _buildSearchBar(),
          Expanded(
            child: StreamBuilder<List<Court>>(
              stream: _courtService.getAllCourtsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF5722)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Lỗi tải dữ liệu sân',
                      style: TextStyle(color: _navyColor),
                    ),
                  );
                }

                final courts = snapshot.data ?? <Court>[];
                final query = _searchController.text.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? courts
                    : courts
                          .where(
                            (court) =>
                                court.name.toLowerCase().contains(query) ||
                                court.address.toLowerCase().contains(query),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('Chưa có sân nào'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildCourtCard(filtered[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _canCreate ? Container(
        margin: const EdgeInsets.only(bottom: 32),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.courtCreate);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5722), Color(0xFFFF8A65)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _orangeColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 32, color: Colors.white),
          ),
        ),
      ) : null,
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, size: 28, color: _navyColor),
              ),
            ),
            Expanded(
              child: Text(
                'Danh Sách Sân',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm tên sân, địa chỉ...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: IconButton(
              icon: Icon(Icons.tune, color: Colors.grey[500]),
              onPressed: () {
                // TODO: Implement filter
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: _orangeColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourtCard(Court court) {
    final isAvailable = court.status == 'available';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.courtDetail,
          arguments: {'id': court.id},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    height: 176,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: court.imageUrl == null || court.imageUrl!.isEmpty
                        ? Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : Image.network(
                            court.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAvailable
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green[500]
                                : Colors.red[500],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAvailable ? 'Sẵn sàng' : 'Bảo trì',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isAvailable
                                ? Colors.green[600]
                                : Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _navyColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconForSport(court.sportType),
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          court.sportType,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          court.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _navyColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _formatPrice(court.pricePerHour),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _orangeColor,
                              ),
                            ),
                            TextSpan(
                              text: '/h',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          court.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _canEdit ? () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.courtEdit,
                              arguments: {'id': court.id},
                            );
                          } : null,
                          icon: const Icon(Icons.edit, size: 20),
                          label: const Text(
                            'Chỉnh sửa',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[50],
                            foregroundColor: _navyColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 56,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _canDelete ? () {
                            _showDeleteDialog(court.id, court.name);
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.05),
                            foregroundColor: Colors.red[400],
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.red.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                          child: const Icon(Icons.delete, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String courtId, String courtName) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Bạn có chắc chắn muốn xóa "$courtName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await _courtService.deleteCourt(courtId);
                  if (!mounted) {
                    return;
                  }
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa "$courtName"'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (_) {
                  if (!mounted) {
                    return;
                  }
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Xóa sân thất bại'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  IconData _iconForSport(String sport) {
    final lower = sport.toLowerCase();
    if (lower.contains('cầu lông')) {
      return Icons.sports_tennis;
    }
    if (lower.contains('tennis')) {
      return Icons.sports_baseball;
    }
    return Icons.sports_soccer;
  }

  String _formatPrice(int value) {
    if (value <= 0) {
      return '0';
    }
    return '${(value / 1000).round()}k';
  }
}

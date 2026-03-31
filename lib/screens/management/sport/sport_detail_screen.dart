import 'package:flutter/material.dart';
import 'package:sportset_admin/models/sport.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/screens/management/sport/sport_icon_mapper.dart';
import 'package:sportset_admin/services/sport_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// 3.3. Chi tiết môn thể thao (Create/Update)
class SportDetailScreen extends StatefulWidget {
  const SportDetailScreen({super.key});

  @override
  State<SportDetailScreen> createState() => _SportDetailScreenState();
}

class _SportDetailScreenState extends State<SportDetailScreen> {
  final SportService _sportService = SportService();
  final AccessControlService _accessControlService = AccessControlService();
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  
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
      _canEdit = _accessControlService.can(permissionMap, 'sports', 'update');
      _canDelete = _accessControlService.can(permissionMap, 'sports', 'delete');
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final sportId = args is Map ? args['id'] as String? : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F6),
        title: Text(
          'Chi tiết danh mục',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _navyColor,
          ),
        ),
      ),
      body: sportId == null || sportId.isEmpty
          ? const Center(child: Text('Không tìm thấy mã danh mục'))
          : StreamBuilder<Sport?>(
              stream: _sportService.getSportByIdStream(sportId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Không thể tải thông tin danh mục',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  );
                }

                final sport = snapshot.data;
                if (sport == null) {
                  return const Center(
                    child: Text('Danh mục không tồn tại hoặc đã bị xóa'),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: _orangeColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                SportIconMapper.iconFromKey(sport.iconKey),
                                size: 42,
                                color: _orangeColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              sport.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: _navyColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sport.description.isEmpty
                                  ? 'Chưa có mô tả'
                                  : sport.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildInfoChip('${sport.itemCount} sân hiện có'),
                                _buildInfoChip(
                                  sport.isVisible
                                      ? 'Đang hiển thị'
                                      : 'Đang ẩn',
                                ),
                                _buildInfoChip(
                                  SportIconMapper.labelFromKey(sport.iconKey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _canDelete
                                  ? () => _showDeleteDialog(sport)
                                  : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _canDelete ? Colors.red : Colors.grey,
                                side: BorderSide(
                                  color: _canDelete
                                      ? Colors.red
                                      : Colors.grey.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                'Xóa',
                                style: TextStyle(
                                  color: _canDelete ? Colors.red : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _canEdit
                                  ? () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.sportEdit,
                                        arguments: {'id': sport.id},
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canEdit
                                    ? _orangeColor
                                    : Colors.grey.withValues(alpha: 0.5),
                              ),
                              child: Text(
                                'Chỉnh sửa',
                                style: TextStyle(
                                  color:
                                      _canEdit ? Colors.white : Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _orangeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _orangeColor,
        ),
      ),
    );
  }

  void _showDeleteDialog(Sport sport) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa môn thể thao'),
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
                    const SnackBar(content: Text('Đã xóa danh mục thành công')),
                  );
                  Navigator.pop(context);
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
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

